defmodule GithubPagesConnector.Connections do
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.Connection

  @repo GithubPagesConnector.ConnectionMemoryRepo
  @github Application.get_env(:github_pages_connector, :github)
  @dnsimple Application.get_env(:github_pages_connector, :dnsimple)

  def list_connections(account = %Account{}), do: list_connections(account.dnsimple_account_id)
  def list_connections(dnsimple_account_id), do: @repo.list_connections(dnsimple_account_id)

  def new_connection(account, connection_data) do
    connection_data = Keyword.merge(connection_data, dnsimple_account_id: account.dnsimple_account_id)

    struct(Connection, connection_data)
    |> add_records(account)
    |> add_cname_file(account)
    |> @repo.put
  end

  def remove_connection(account, connection_id) do
    @repo.get(connection_id)
    |> remove_records(account)
    |> @repo.remove
  end

  defp add_records(connection, account) do
    record_data   = %{name: "", type: "ALIAS", content: connection.github_repository}
    {:ok, record} = @dnsimple.create_record(account, connection.dnsimple_domain, record_data)
    Map.put(connection, :dnsimple_record_ids, [record.id])
  end

  defp remove_records(connection, account) do
    Enum.each(connection.dnsimple_record_ids, fn(record_id) ->
      :ok = @dnsimple.delete_record(account, connection.dnsimple_domain, record_id)
    end)
    Map.put(connection, :dnsimple_record_ids, [])
  end

  defp add_cname_file(connection, account) do
    file_path    = "CNAME"
    file_content = connection.dnsimple_domain
    {:ok, _file} = @github.create_file(account, connection.github_repository, file_path, file_content)
    connection
  end

end
