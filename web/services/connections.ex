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
    |> disable_one_click_service(account)
    |> add_alias_record(account)
    |> add_cname_record(account)
    |> configure_cname_file(account)
    |> @repo.put
  end

  def remove_connection(account, connection_id) do
    @repo.get(connection_id)
    |> remove_alias_record(account)
    |> remove_cname_record(account)
    |> remove_cname_file(account)
    |> @repo.remove
  end

  # Record management
  ##############################################################################

  defp add_alias_record(connection, account) do
    record_data   = %{name: "", type: "ALIAS", content: connection.github_repository}
    {:ok, record} = @dnsimple.create_record(account, connection.dnsimple_domain, record_data)
    Map.put(connection, :dnsimple_alias_id, record.id)
  end

  defp add_cname_record(connection, account) do
    record_data   = %{name: "www", type: "CNAME", content: connection.dnsimple_domain}
    {:ok, record} = @dnsimple.create_record(account, connection.dnsimple_domain, record_data)
    Map.put(connection, :dnsimple_cname_id, record.id)
  end

  defp remove_alias_record(connection, account) do
    :ok = @dnsimple.delete_record(account, connection.dnsimple_domain, connection.dnsimple_alias_id)
    Map.put(connection, :dnsimple_alias_id, nil)
  end

  defp remove_cname_record(connection, account) do
    :ok = @dnsimple.delete_record(account, connection.dnsimple_domain, connection.dnsimple_cname_id)
    Map.put(connection, :dnsimple_cname_id, nil)
  end


  # CNAME file management
  ##############################################################################

  @cname_file_path "CNAME"

  def configure_cname_file(connection, account) do
    case get_cname_file(connection.github_repository, account) do
      {:ok, %{sha: sha}}  -> update_cname_file(connection, account, sha)
      {:error, :notfound} -> create_cname_file(connection, account)
      {:error, error}     -> {:error, error}
    end
  end

  def get_cname_file(repository, account) do
    @github.get_file(account, repository, @cname_file_path)
  end

  def create_cname_file(connection, account) do
    {:ok, commit} = @github.create_file(account, connection.github_repository, @cname_file_path, connection.dnsimple_domain, "Configure custom domain with DNSimple")
    Map.put(connection, :github_file_sha, commit["content"]["sha"])
  end

  def update_cname_file(connection, account, existing_file_sha) do
    {:ok, commit} = @github.update_file(account, connection.github_repository, @cname_file_path, connection.dnsimple_domain, existing_file_sha, "Configure custom domain with DNSimple")
    Map.put(connection, :github_file_sha, commit["content"]["sha"])
  end

  def remove_cname_file(connection, account) do
    {:ok, _commit} = @github.delete_file(account, connection.github_repository, @cname_file_path, connection.github_file_sha, "Remove DNSimple custom domain configuration")
    Map.put(connection, :github_file_sha, nil)
  end


  # 1-click-service management
  #############################################################################

  defp disable_one_click_service(connection, account) do
    if github_pages_service = get_github_pages_applied_service(connection, account) do
      :ok = @dnsimple.disable_service(account, connection.dnsimple_domain, github_pages_service.id)
    end
    connection
  end

  defp get_github_pages_applied_service(connection, account) do
    {:ok, applied_services} = @dnsimple.get_applied_services(account, connection.dnsimple_domain)
    Enum.find(applied_services, &(&1.name == "GitHub Pages"))
  end


  #############################################################################
  #############################################################################
  #############################################################################
  #############################################################################
  #############################################################################

  alias GithubPagesConnector.TransactionalPipeline

  def new_new_connection(account, connection_data) do
    connection = struct(Connection, Keyword.merge(connection_data, account_id: account.id))
    pipeline   = [
      &new_add_alias_record/2,
      &new_add_cname_record/2,
      &force_error/2,
    ]

    case TransactionalPipeline.run(pipeline, [connection, account]) do
      {:ok, [connection, account]} ->
        IO.inspect(connection)
        @repo.put(connection)
      {:error, error} ->
        {:error, error}
    end
  end

  defp force_error(_connection, _acccount), do: {:error, "forced error"}


  # Record management
  ##############################################################################

  defp new_add_alias_record(connection, account) do
    record_data = %{name: "", type: "ALIAS", content: connection.github_repository}
    case @dnsimple.create_record(account, connection.dnsimple_domain, record_data) do
      {:ok, record} ->
        connection = Map.put(connection, :dnsimple_alias_id, record.id)
        revert     = fn -> new_remove_alias_record(connection, account) end
        {:ok, [connection, account], [revert]}
      {:error, details} ->
        {:error, details}
    end
  end

  defp new_add_cname_record(connection, account) do
    record_data = %{name: "www", type: "CNAME", content: connection.dnsimple_domain}
    case @dnsimple.create_record(account, connection.dnsimple_domain, record_data) do
      {:ok, record} ->
        connection = Map.put(connection, :dnsimple_cname_id, record.id)
        revert     = fn -> new_remove_cname_record(connection, account) end
        {:ok, [connection, account], [revert]}
      {:error, details} ->
        {:error, details}
    end
  end

  defp new_remove_alias_record(connection, account) do
    case @dnsimple.delete_record(account, connection.dnsimple_domain, connection.dnsimple_alias_id) do
      :ok ->
        connection = Map.put(connection, :dnsimple_alias_id, nil)
        revert     = fn -> new_add_alias_record(connection, account) end
        {:ok, [connection, account], [revert]}
      {:error, error} ->
        {:error, error}
    end
  end

  defp new_remove_cname_record(connection, account) do
    case @dnsimple.delete_record(account, connection.dnsimple_domain, connection.dnsimple_cname_id) do
      :ok ->
        connection = Map.put(connection, :dnsimple_cname_id, nil)
        revert     = fn -> new_add_cname_record(connection, account) end
        {:ok, [connection, account], [revert]}
      {:error, error} ->
        {:error, error}
    end
  end

end
