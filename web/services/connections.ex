defmodule GithubPagesConnector.Services.Connections do
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.Connection

  @repo GithubPagesConnector.ConnectionEctoRepo
  @github Application.get_env(:github_pages_connector, :github)
  @dnsimple Application.get_env(:github_pages_connector, :dnsimple)

  def list_pages_repositories(account = %Account{}) do
    {:ok, repositories} = @github.list_all_repositories(account)
    Enum.filter(repositories, fn(repo) -> String.ends_with?(repo["name"], "github.io") end)
  end

  def list_domains(account = %Account{}) do
    {:ok, domains} = @dnsimple.list_all_domains(account)
    domains
  end

  def list_connections(account = %Account{}), do: list_connections(account.id)
  def list_connections(account_id), do: @repo.list_connections(account_id)

  def new_connection(account, connection_data) do
    connection_data = Keyword.merge(connection_data, account_id: account.id)

    struct(Connection, connection_data)
    |> add_alias_record(account)
    |> add_cname_file(account)
    |> @repo.put
  end

  def remove_connection(account, connection_id) do
    @repo.get(connection_id)
    |> remove_alias_record(account)
    |> remove_cname_file(account)
    |> @repo.remove
  end

  defp add_alias_record(connection, account) do
    record_data   = %{name: "", type: "ALIAS", content: connection.github_repository}
    {:ok, record} = @dnsimple.create_record(account, connection.dnsimple_domain, record_data)
    Map.put(connection, :dnsimple_record_id, record.id)
  end

  defp remove_alias_record(connection, account) do
    :ok = @dnsimple.delete_record(account, connection.dnsimple_domain, connection.dnsimple_record_id)
    Map.put(connection, :dnsimple_record_id, nil)
  end


  @cname_file_path "CNAME"

  def get_cname_file(account = %Account{}, repository) do
    @github.get_file(account, repository, @cname_file_path)
  end

  defp add_cname_file(connection, account) do
    file_path    = @cname_file_path
    file_content = connection.dnsimple_domain
    {:ok, file}  = @github.create_file(account, connection.github_repository, file_path, file_content)
    Map.put(connection, :github_file_sha, file["content"]["sha"])
  end

  defp remove_cname_file(connection, account) do
    file_path = @cname_file_path
    file_sha  = connection.github_file_sha
    :ok = @github.delete_file(account, connection.github_repository, file_path, file_sha)
    Map.put(connection, :github_file_sha, nil)
  end

end
