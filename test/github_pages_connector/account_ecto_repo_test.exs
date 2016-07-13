defmodule GithubPagesConnector.AccountEctoRepoTest do
  use ExUnit.Case, async: true

  @repo GithubPagesConnector.AccountEctoRepo
  @account %GithubPagesConnector.Account{
    dnsimple_account_id: "dnsimple_account_id",
    dnsimple_account_email: "dnsimple_account_email",
    dnsimple_access_token: "dnsimple_access_token",
    github_account_id: "github_account_id",
    github_account_login: "github_account_login",
    github_access_token: "github_access_token",
  }

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(GithubPagesConnector.Repo)
  end

  describe ".get" do
    test "returns the account" do
      @repo.put(@account)

      account = @repo.get("dnsimple_account_id")
      assert account.dnsimple_account_id == @account.dnsimple_account_id
      assert account.dnsimple_account_email == @account.dnsimple_account_email
      assert account.dnsimple_access_token == @account.dnsimple_access_token
      assert account.github_account_id == @account.github_account_id
      assert account.github_account_login == @account.github_account_login
      assert account.github_access_token == @account.github_access_token
    end

    test "returns nil if there's no account with given dnsimple_account_id" do
      assert @repo.get("does_not_exist") == nil
    end

    test "handles numeric ids" do
      @repo.put(%GithubPagesConnector.Account{dnsimple_account_id: 12345})

      refute @repo.get(12345) == nil
    end
  end

  describe ".put" do
    test "assigns the account id" do
      account = @repo.put(@account)

      assert @account.id == nil
      refute account.id == nil
    end

    test "stores the account" do
      account = @repo.put(@account)

      account = @repo.get(account.dnsimple_account_id)
      assert account.dnsimple_account_id == @account.dnsimple_account_id
      assert account.dnsimple_account_email == @account.dnsimple_account_email
      assert account.dnsimple_access_token == @account.dnsimple_access_token
      assert account.github_account_id == @account.github_account_id
      assert account.github_account_login == @account.github_account_login
      assert account.github_access_token == @account.github_access_token
    end

    @tag :skip
    test "overwrites the account if it was already stored" do
      stored_account  = @repo.put(%GithubPagesConnector.Account{})
      updated_account = Map.put(@account, :id, stored_account.id)

      @repo.put(updated_account)

      account = @repo.get(stored_account.id)
      assert account.dnsimple_account_id == @account.dnsimple_account_id
      assert account.dnsimple_account_email == @account.dnsimple_account_email
      assert account.dnsimple_access_token == @account.dnsimple_access_token
      assert account.github_account_id == @account.github_account_id
      assert account.github_account_login == @account.github_account_login
      assert account.github_access_token == @account.github_access_token
    end
  end

end
