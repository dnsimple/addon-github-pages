defmodule GithubPagesConnector.MemoryRepoTest do
  use ExUnit.Case
  alias GithubPagesConnector.MemoryRepo

  @account_id 1

  setup do
    {:ok, _pid} = MemoryRepo.start_link
    :ok
  end

  describe "get" do
    test "returns the account stored under given key" do
      MemoryRepo.put(@account_id, :account)

      assert MemoryRepo.get(@account_id) == :account
    end

    test "returns nil if no account was stored given key" do
      assert MemoryRepo.get(@account_id) == nil
    end
  end

  describe "put" do
    test "stores the account under given key" do
      MemoryRepo.put(@account_id, :account)

      assert MemoryRepo.get(@account_id) == :account
    end

    test "overwrites the account if another account was stored under given key" do
      MemoryRepo.put(@account_id, :account)
      MemoryRepo.put(@account_id, :other)

      assert MemoryRepo.get(@account_id) == :other
    end
  end

end
