defmodule GithubPagesConnector.ConnectionEctoRepo do
  import Ecto.Query, only: [from: 2]
  alias GithubPagesConnector.Repo
  alias GithubPagesConnector.Connection

  def list_connections(account_id) do
    query = from c in Connection,
          where: c.account_id == ^account_id,
       order_by: c.account_id
    Repo.all(query)
  end

  def get(connection_id) do
    Repo.get(Connection, connection_id)
  end

  def put(connection) do
    case connection.id do
      nil               -> insert(connection)
      old_connection_id -> get(old_connection_id) |> update(connection)
    end
  end

  def remove(connection) do
    Repo.delete!(connection)
  end


  defp insert(connection) do
    Connection.changeset(connection, connection)
    |> Repo.insert!
  end

  defp update(connection, updated_connection) do
    Connection.changeset(connection, updated_connection)
    |> Repo.update!
  end

end
