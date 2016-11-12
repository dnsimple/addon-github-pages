defmodule GithubPagesConnector.ConnectionControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Services.Accounts
  @connections GithubPagesConnector.Services.Connections
  @github GithubPagesConnector.GithubDummy
  @dnsimple GithubPagesConnector.DnsimpleDummy

  setup do
    @github.reset
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
      @dnsimple.stub(:list_all_domains, {:ok, [
        %Dnsimple.Domain{name: "domain1.com"},
        %Dnsimple.Domain{name: "domain2.com"}
      ]})

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

  describe ".preview" do
    test "displays the preview of the connection", %{conn: conn} do
      conn = post(conn, connection_path(conn, :preview), repository: "repo1", domain: "domain1.com")

      response = html_response(conn, 200)
      assert response =~ "Connecting"
      assert response =~ "Create connection"
    end

    test "displays the new content for the CNAME file", %{conn: conn} do
      @github.stub(:get_file, {:error, :notfound})

      conn = post(conn, connection_path(conn, :preview), repository: "repo1", domain: "domain1.com")

      response = html_response(conn, 200)
      assert response =~ "A new file is going to be created"
      assert response =~ "domain1.com"
    end


    test "displays the existing CNAME file content if it exists", %{conn: conn} do
      @github.stub(:get_file, {:ok, %{content: "existing content"}})

      conn = post(conn, connection_path(conn, :preview), repository: "repo1", domain: "domain1.com")

      response = html_response(conn, 200)
      assert response =~ "A file has been found"
      assert response =~ "existing content"
      assert response =~ "domain1.com"
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
      refute connection.dnsimple_alias_id == nil
      assert {:create_record, [account, "domain1.com", %{name: "", type: "ALIAS", content: "repo1"}]} in @dnsimple.calls
      assert {:create_record, [account, "domain1.com", %{name: "www", type: "CNAME", content: "domain1.com"}]} in @dnsimple.calls
    end

    test "creates the CNAME file in the GitHub repo", %{conn: conn, account: account} do
      @github.stub(:get_file, {:error, :notfound})

      post(conn, connection_path(conn, :create), repository: "repo1", domain: "domain1.com")

      assert {:create_file, [account, "repo1", "CNAME", "domain1.com", "Configure custom domain with DNSimple"]} in @github.calls
    end

    test "updates the CNAME file in the GitHub repo if a CNAME file existed", %{conn: conn, account: account} do
      @github.stub(:get_file, {:ok, %{sha: "existing-sha"}})

      post(conn, connection_path(conn, :create), repository: "repo1", domain: "domain1.com")

      assert {:update_file, [account, "repo1", "CNAME", "domain1.com", "existing-sha", "Configure custom domain with DNSimple"]} in @github.calls
    end

    test "removes the GitHub Pages 1-click-service on DNSimple if applied", %{conn: conn, account: account} do
      @dnsimple.stub(:get_applied_services, {:ok, [service = %Dnsimple.Service{id: 123, name: "GitHub Pages"}]})

      post(conn, connection_path(conn, :create), repository: "repo1", domain: "domain1.com")

      assert {:disable_service, [account, "domain1.com", service.id]} in @dnsimple.calls
    end
  end

  describe ".delete" do
    setup %{conn: conn, account: account} do
      {:ok, connection} = @connections.new_connection(account, [dnsimple_domain: "domain1.com", github_repository: "repo1"])
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

    test "removes the created records in DNSimple", %{conn: conn, account: account, connection: connection} do
      delete(conn, connection_path(conn, :delete, connection))

      assert {:delete_record, [account, connection.dnsimple_domain, connection.dnsimple_alias_id]} in @dnsimple.calls
      assert {:delete_record, [account, connection.dnsimple_domain, connection.dnsimple_cname_id]} in @dnsimple.calls
    end

    test "removes the CNAME file from the GitHub repo", %{conn: conn, account: account, connection: connection} do
      delete(conn, connection_path(conn, :delete, connection))

      assert {:delete_file, [account, connection.github_repository, "CNAME", connection.github_file_sha, "Remove DNSimple custom domain configuration"]} in @github.calls
    end
  end

end
