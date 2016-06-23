defmodule GithubPagesConnector.MemoryRepoTest do
  use ExUnit.Case
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.MemoryRepo

  @account_id 1
  @account %Account{dnsimple_account_id: @account_id}

  describe "get" do
    test "returns the account stored under given key" do
      MemoryRepo.put(@account_id, @account)

      assert MemoryRepo.get(@account_id) == @account
    end

    test "returns nil if no account was stored given key" do
      assert MemoryRepo.get(:other_id) == nil
    end
  end

  describe "put" do
    test "stores the account under given key" do
      MemoryRepo.put(@account_id, @account)

      assert MemoryRepo.get(@account_id) == @account
    end

    test "overwrites the account if another account was stored under given key" do
      MemoryRepo.put(@account_id, @account)
      MemoryRepo.put(@account_id, %Account{dnsimple_account_id: "1234"})

      assert MemoryRepo.get(@account_id) == %Account{dnsimple_account_id: "1234"}
    end
  end

end
