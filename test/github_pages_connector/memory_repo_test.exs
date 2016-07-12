defmodule GithubPagesConnector.MemoryRepoTest do
  use ExUnit.Case
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.MemoryRepo

  @account_id 1
  @account %Account{dnsimple_account_id: @account_id}

  describe "get" do
    test "returns the account stored under given key" do
      MemoryRepo.put(@account)

      assert MemoryRepo.get(@account_id) == @account
    end

    test "returns nil if no account was stored given key" do
      assert MemoryRepo.get(:other_id) == nil
    end
  end

  describe "put" do
    test "stores the account under the account's dnsimple account id" do
      MemoryRepo.put(@account)

      assert MemoryRepo.get(@account_id) == @account
    end

    test "overwrites the account if another account with the same dnsimple account id exists" do
      MemoryRepo.put(@account)

      account = %Account{dnsimple_account_id: @account_id, dnsimple_account_email: "dnsimple_account_email"}
      MemoryRepo.put(account)

      refute MemoryRepo.get(@account_id) == @account
      assert MemoryRepo.get(@account_id) == account
    end
  end

end
