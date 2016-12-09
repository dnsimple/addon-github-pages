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

  def put_attribute(connection, attribute_name, attribute_value) do
    Connection.attribute_changeset(connection, attribute_name, attribute_value)
    |> Repo.update
  end

  def remove(connection) do
    case Repo.delete(connection) do
      {:ok, removed_connection} -> {:ok, Map.put(removed_connection, :id, nil)}
      {:error, details}         -> {:error, details}
    end
  end


  defp insert(connection) do
    Connection.upsert_changeset(connection, connection)
    |> Repo.insert
  end

  defp update(connection, updated_connection) do
    Connection.upsert_changeset(connection, updated_connection)
    |> Repo.update
  end

end
