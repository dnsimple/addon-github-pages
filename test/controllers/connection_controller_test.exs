defmodule GithubPagesConnector.ConnectionControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Accounts
  @connections GithubPagesConnector.Connections

  setup do
    GithubPagesConnector.ConnectionMemoryRepo.reset

    account = @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")
    conn    = assign(build_conn, :current_account_id, account.dnsimple_account_id)
    {:ok, conn: conn, account: account}
  end

  describe ".index" do
    test "lists the existing connections for signed in account", %{conn: conn, account: account} do
      @connections.new_connection(dnsimple_account_id: account.dnsimple_account_id)

      conn = get(conn, connection_path(conn, :index))

      assert html_response(conn, 200) =~ "Existing connections"
    end

    test "redirects to new if signed in account has no connection", %{conn: conn} do
      conn = get(conn, connection_path(conn, :index))

      assert redirected_to(conn) == connection_path(conn, :new)
    end
  end

  describe ".new" do
    test "displays view to create a new connection", %{conn: conn} do
      conn = get(conn, connection_path(conn, :new))

      response = html_response(conn, 200)

      assert response =~ "New connection"
      assert response =~ "repo1"
      assert response =~ "repo2"
      assert response =~ "repo3"
      assert response =~ "domain1.com"
      assert response =~ "domain2.com"
    end
  end

end
