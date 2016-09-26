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
      {:ok, _} = @repo.put(@account)

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
      {:ok, _} = @repo.put(%GithubPagesConnector.Account{dnsimple_account_id: 12345})

      refute @repo.get(12345) == nil
    end
  end

  describe ".put" do
    test "assigns the account id" do
      {:ok, account} = @repo.put(@account)

      assert @account.id == nil
      refute account.id == nil
    end

    test "stores the account" do
      {:ok, account} = @repo.put(@account)

      account = @repo.get(account.dnsimple_account_id)
      assert account.dnsimple_account_id == @account.dnsimple_account_id
      assert account.dnsimple_account_email == @account.dnsimple_account_email
      assert account.dnsimple_access_token == @account.dnsimple_access_token
      assert account.github_account_id == @account.github_account_id
      assert account.github_account_login == @account.github_account_login
      assert account.github_access_token == @account.github_access_token
    end

    test "overwrites the account if it was already stored" do
      {:ok, _} = @repo.put(@account)

      {:ok, _} = @account
      |> Map.put(:dnsimple_account_email, "updated_dnsimple_account_email")
      |> Map.put(:dnsimple_access_token, "updated_dnsimple_access_token")
      |> @repo.put

      account = @repo.get(@account.dnsimple_account_id)
      assert account.dnsimple_account_email == "updated_dnsimple_account_email"
      assert account.dnsimple_access_token == "updated_dnsimple_access_token"
    end
  end

end
