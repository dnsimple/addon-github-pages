defmodule GithubPagesConnector.DnsimpleOauthControllerTest do
  use GithubPagesConnector.ConnCase

  describe "GET /dnsimple/authorize" do
    test "starts the DNSimple OAuth dance", %{conn: conn} do
      conn = get conn, dnsimple_oauth_path(conn, :new)
      assert redirected_to(conn) =~ "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
    end
  end

  describe "GET /dnsimple/callback" do
    test "starts the GitHub OAuth dance", %{conn: conn} do
      conn = get conn, dnsimple_oauth_path(conn, :create)
      assert redirected_to(conn) =~ github_oauth_path(conn, :new)
    end
  end

end
