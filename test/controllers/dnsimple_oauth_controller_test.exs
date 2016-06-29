defmodule GithubPagesConnector.DnsimpleOauthControllerTest do
  use GithubPagesConnector.ConnCase

  describe "GET /dnsimple/authorize" do
    test "starts the DNSimple OAuth dance", %{conn: conn} do
      conn = get conn, dnsimple_oauth_path(conn, :new)
      assert redirected_to(conn) =~ "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
    end
  end

  describe "GET /dnsimple/callback" do
    test "puts the DNSimple account id and access token in the session", %{conn: conn} do
      conn = get conn, dnsimple_oauth_path(conn, :create)
      assert get_session(conn, :dnsimple_account_id) == "account_id"
      assert get_session(conn, :dnsimple_access_token) == "access_token"
    end

    test "starts the GitHub OAuth dance", %{conn: conn} do
      conn = get conn, dnsimple_oauth_path(conn, :create)
      assert redirected_to(conn) =~ github_oauth_path(conn, :new)
    end
  end

end
