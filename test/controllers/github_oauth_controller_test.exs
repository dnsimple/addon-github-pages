defmodule GithubPagesConnector.GithubOauthControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Accounts

  describe ".new" do
    test "starts the DNSimple OAuth dance if no account is signed in", %{conn: conn} do
      conn = get(conn, github_oauth_path(conn, :new))

      assert redirected_to(conn) =~ "/dnsimple/authorize"
    end

    test "starts the GitHub OAuth dance if an account was signed in", %{conn: conn} do
      @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")

      conn = conn
      |> assign(:current_account_id, "dnsimple_account_id")
      |> get(github_oauth_path(conn, :new))

      assert redirected_to(conn) =~ "https://test.github.com/auth/authorize?client_id=client_id&state=state"
    end
  end

  describe ".create" do
    test "starts the DNSimple OAuth dance if no account is signed in", %{conn: conn} do
      conn = get(conn, github_oauth_path(conn, :create))

      assert redirected_to(conn) =~ "/dnsimple/authorize"
    end

    test "adds the GitHub data to the account if an account was signed in", %{conn: conn} do
      @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")

      conn
      |> assign(:current_account_id, "dnsimple_account_id")
      |> get(github_oauth_path(conn, :create))

      account = @accounts.get_account("dnsimple_account_id")
      assert account.github_account_id == "github_account_id"
      assert account.github_account_login == "github_account_login"
      assert account.github_access_token == "github_access_token"
    end

    test "redirects to new connection creation if an account was signed in", %{conn: conn} do
      @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")

      conn = conn
      |> assign(:current_account_id, "dnsimple_account_id")
      |> get(github_oauth_path(conn, :create))

      assert redirected_to(conn) =~ connection_path(conn, :new)
    end
  end

end
