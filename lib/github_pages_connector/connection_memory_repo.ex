defmodule GithubPagesConnector.ConnectionMemoryRepo do
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def debug do
    Agent.get(__MODULE__, &IO.inspect/1)
  end

  def reset do
    Agent.update(__MODULE__, fn -> %{} end)
  end

  def get(connection_id) do
    Agent.get(__MODULE__, &Map.get(&1, connection_id))
  end

  def list_connections(dnsimple_account_id) do
    Agent.get(__MODULE__, &(&1))
    |> Map.values
    |> Enum.filter(fn(connection) -> connection.dnsimple_account_id == dnsimple_account_id end)
  end

  def put(connection) do
    connection = Map.put(connection, :id, random_id)
    Agent.update(__MODULE__, &Map.put(&1, connection.id, connection))
    connection
  end

  defp random_id, do: :rand.uniform(10000)
end
