defmodule GithubPagesConnector.MemoryRepo do
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def debug do
    Agent.get(__MODULE__, &IO.inspect/1)
  end

  def get(account_id) do
    Agent.get(__MODULE__, &Map.get(&1, account_id))
  end

  def put(account) do
    Agent.update(__MODULE__, &Map.put(&1, account.dnsimple_account_id, account))
  end
end
