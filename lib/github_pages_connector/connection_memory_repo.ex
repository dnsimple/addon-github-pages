defmodule GithubPagesConnector.ConnectionMemoryRepo do
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def debug do
    Agent.get(__MODULE__, &IO.inspect/1)
  end

  def reset do
    Agent.update(__MODULE__, fn(_) -> %{} end)
  end

  def list_connections(account_id) do
    Agent.get(__MODULE__, &(&1))
    |> Map.values
    |> Enum.filter(fn(connection) -> connection.account_id == account_id end)
  end

  def get(connection_id) do
    Agent.get(__MODULE__, &Map.get(&1, connection_id))
  end

  def put(connection) do
    connection = Map.put(connection, :id, random_id)
    Agent.update(__MODULE__, &Map.put(&1, connection.id, connection))
    connection
  end

  def remove(nil), do: nil
  def remove(connection) do
    Agent.update(__MODULE__, &Map.delete(&1, connection.id))
    connection
  end

  defp random_id, do: :rand.uniform(10000) |> to_string
end
