defmodule GithubPagesConnector.DnsimpleOauthControllerTest do
  use GithubPagesConnector.ConnCase
  alias GithubPagesConnector.Account

  @repo GithubPagesConnector.MemoryRepo

  describe ".new" do
    test "starts the DNSimple OAuth dance", %{conn: conn} do
      conn = get(conn, dnsimple_oauth_path(conn, :new))

      assert redirected_to(conn) =~ "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
    end
  end

  describe ".create" do
    test "signs up the account", %{conn: conn} do
      get(conn, dnsimple_oauth_path(conn, :create))

      account = @repo.get("dnsimple_account_id")

      refute account == nil
      assert account.dnsimple_account_id == "dnsimple_account_id"
      assert account.dnsimple_account_email == "dnsimple_account_email"
      assert account.dnsimple_access_token == "dnsimple_access_token"
    end

    test "updates the account data when the account had already signed up", %{conn: conn} do
      @repo.put("dnsimple_account_id", %Account{
        dnsimple_account_id: "dnsimple_account_id",
        dnsimple_account_email: "old_dnsimple_account_email",
        dnsimple_access_token: "old_dnsimple_access_token",
      })

      get(conn, dnsimple_oauth_path(conn, :create))

      account = @repo.get("dnsimple_account_id")
      assert account.dnsimple_account_email == "dnsimple_account_email"
      assert account.dnsimple_access_token == "dnsimple_access_token"
    end

    test "starts the GitHub OAuth dance", %{conn: conn} do
      conn = get(conn, dnsimple_oauth_path(conn, :create))

      assert redirected_to(conn) =~ github_oauth_path(conn, :new)
    end
  end

end
