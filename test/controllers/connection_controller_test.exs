defmodule GithubPagesConnector.ConnectionControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Services.Accounts
  @connections GithubPagesConnector.Services.Connections
  @dnsimple GithubPagesConnector.DnsimpleDummyAgent

  setup do
    @dnsimple.reset
    {:ok, account} = @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")
    conn           = assign(build_conn, :current_account_id, account.dnsimple_account_id)
    {:ok, conn: conn, account: account}
  end

  describe ".index" do
    test "lists the existing connections for signed in account", %{conn: conn, account: account} do
      @connections.new_connection(account, [])

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
      @dnsimple.stub(:list_all_domains, [
        %Dnsimple.Domain{name: "domain1.com"},
        %Dnsimple.Domain{name: "domain2.com"}
      ])

      conn = get(conn, connection_path(conn, :new))

      response = html_response(conn, 200)
      assert response =~ "New connection"
      assert response =~ "domain1.com"
      assert response =~ "domain2.com"
      assert response =~ "user.github.io"
      assert response =~ "org.github.io"
      refute response =~ "project"
    end
  end

  describe ".create" do
    test "redirects to the connection list", %{conn: conn} do
      conn = post(conn, connection_path(conn, :create), repository: "repo1", domain: "domain1.com")

      assert redirected_to(conn) == connection_path(conn, :index)
    end

    test "adds a new connection", %{conn: conn, account: account} do
      post(conn, connection_path(conn, :create), repository: "repo1", domain: "domain1.com")

      [connection] = @connections.list_connections(account)
      assert connection.account_id == account.id
      assert connection.dnsimple_domain == "domain1.com"
      assert connection.github_repository == "repo1"
    end

    test "adds necessary records on DNSimple and records the reference", %{conn: conn, account: account} do
      post(conn, connection_path(conn, :create), repository: "repo1", domain: "domain1.com")

      [connection] = @connections.list_connections(account)
      refute connection.dnsimple_record_id == nil
      assert {:create_record, [account, "domain1.com", %{name: "", type: "ALIAS", content: "repo1"}]} in @dnsimple.calls
    end

    @tag :skip
    test "creates the CNAME file in the GitHub repo"

    @tag :skip
    test "updates the CNAME file in the GitHub repo if a CNAME file existed"

    test "removes the GitHub Pages 1-click-service on DNSimple if applied", %{conn: conn, account: account} do
      @dnsimple.stub(:get_applied_services, [service = %Dnsimple.Service{id: 123, name: "GitHub Pages"}])

      post(conn, connection_path(conn, :create), repository: "repo1", domain: "domain1.com")

      assert {:disable_service, [account, "domain1.com", service.id]} in @dnsimple.calls
    end
  end

  describe ".delete" do
    setup %{conn: conn, account: account} do
      {:ok, connection} = @connections.new_connection(account, [])
      {:ok, conn: conn, account: account, connection: connection}
    end

    test "redirects to the connection list", %{conn: conn, connection: connection} do
      conn = delete(conn, connection_path(conn, :delete, connection))

      assert redirected_to(conn) == connection_path(conn, :index)
    end

    test "deletes the connection", %{conn: conn, account: account, connection: connection} do
      delete(conn, connection_path(conn, :delete, connection))

      assert @connections.list_connections(account) == []
    end

    test "removes the created ALIAS record in DNSimple", %{conn: conn, account: account, connection: connection} do
      delete(conn, connection_path(conn, :delete, connection))

      assert {:delete_record, [account, connection.dnsimple_domain, connection.dnsimple_record_id]} in @dnsimple.calls
    end

    @tag :skip
    test "remvoes the CNAME file in the GitHub repo"
  end

end
