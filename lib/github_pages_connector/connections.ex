defmodule GithubPagesConnector.Connections do
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.Connection

  @repo GithubPagesConnector.ConnectionMemoryRepo

  def list_connections(account = %Account{}), do: list_connections(account.dnsimple_account_id)
  def list_connections(dnsimple_account_id), do: @repo.list_connections(dnsimple_account_id)

  def new_connection(connection_data) do
    struct(Connection, connection_data)
    |> @repo.put
  end

end
