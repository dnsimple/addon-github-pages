defmodule GithubPagesConnector.AccountMemoryRepoTest do
  use ExUnit.Case
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.AccountMemoryRepo

  @account_id 1
  @account %Account{dnsimple_account_id: @account_id}
  @repo AccountMemoryRepo

  describe "get" do
    test "returns the account stored under given key" do
      @repo.put(@account)

      assert @repo.get(@account_id) == @account
    end

    test "returns nil if no account was stored given key" do
      assert @repo.get(:other_id) == nil
    end
  end

  describe "put" do
    test "stores the account under the account's dnsimple account id" do
      @repo.put(@account)

      assert @repo.get(@account_id) == @account
    end

    test "overwrites the account if another account with the same dnsimple account id exists" do
      @repo.put(@account)

      account = %Account{dnsimple_account_id: @account_id, dnsimple_account_email: "dnsimple_account_email"}
      @repo.put(account)

      refute @repo.get(@account_id) == @account
      assert @repo.get(@account_id) == account
    end
  end

end
