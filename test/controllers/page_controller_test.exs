defmodule GithubPagesConnector.PageControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Services.Accounts

  describe "GET /" do
    test "renders index page when not logged in", %{conn: conn} do
      conn = get conn, "/"

      assert html_response(conn, 200) =~ "DNSimple"
    end

    test "redirects to connections when logged in", %{conn: conn} do
      conn = conn
        |> login_account
        |> get("/")

      assert redirected_to(conn) == connection_path(conn, :index)
    end
  end

  describe "GET /login" do
    test "starts OAuth dance when not logged in", %{conn: conn} do
      conn = get conn, "/login"

      assert redirected_to(conn) == dnsimple_oauth_path(conn, :new)
    end

    test "redirects to connections when logged in", %{conn: conn} do
      conn = conn
        |> login_account
        |> get("/login")

      assert redirected_to(conn) == connection_path(conn, :index)
    end
  end

  def login_account(conn) do
    {:ok, account} = @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")
    assign(conn, :current_account_id, account.dnsimple_account_id)
  end

end
