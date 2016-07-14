defmodule GithubPagesConnector.ConnectionControllerTest do
  use GithubPagesConnector.ConnCase

  @accounts GithubPagesConnector.Accounts

  setup do
    account = @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")
    {:ok, conn: build_conn, account: account}
  end

  describe ".index" do
    test "redirects to new if there is no connection", %{conn: conn, account: account} do
      conn = conn
      |> assign(:current_account_id, account.dnsimple_account_id)
      |> get(connection_path(conn, :index))

      assert redirected_to(conn) == connection_path(conn, :new)
    end
  end

end
