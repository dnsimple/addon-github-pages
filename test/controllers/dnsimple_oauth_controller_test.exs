defmodule GithubPagesConnector.DnsimpleOauthControllerTest do
  use GithubPagesConnector.ConnCase

  test "GET /dnsimple/authorize", %{conn: conn} do
    conn = get conn, dnsimple_oauth_path(conn, :new)
    assert redirected_to(conn) =~ "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
  end

  test "GET /dnsimple/callback", %{conn: conn} do
    conn = get conn, dnsimple_oauth_path(conn, :create)
    assert redirected_to(conn) =~ github_oauth_path(conn, :new)
  end

end
