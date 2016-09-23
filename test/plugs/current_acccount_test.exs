defmodule GithubPagesConnector.Plug.CurrentAccountTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias GithubPagesConnector.Plug.CurrentAccount

  @accounts GithubPagesConnector.Services.Accounts
  @session Plug.Session.init(
    store: :cookie,
    key: "_key",
    encryption_salt: "encryption-salt",
    signing_salt: "signing-salt"
  )

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(GithubPagesConnector.Repo)

    account = @accounts.signup_account(dnsimple_account_id: "dnsimple_account_id")
    session_data = %{current_account_id: account.dnsimple_account_id}

    conn = conn(:get, "/")
    |> Map.put(:secret_key_base, String.duplicate("abcdcefg", 8))
    |> Plug.Session.call(@session)
    |> Plug.Conn.fetch_session
    {:ok, conn: conn, account: account, session_data: session_data}
  end

  describe ".call" do
    test "redirects if there is no account in the session", %{conn: conn} do
      conn = CurrentAccount.call(conn, [])

      assert Phoenix.ConnTest.redirected_to(conn) == GithubPagesConnector.Router.Helpers.dnsimple_oauth_path(conn, :new)
    end
  end

  describe ".current_account" do
    test "returns the account if it is in conn.assigns", %{conn: conn, account: account} do
      conn = Plug.Conn.assign(conn, :current_account_id, account.dnsimple_account_id)

      assert CurrentAccount.current_account(conn) == account
    end

    test "returns nil if the account is not in assigns or session", %{conn: conn} do
      assert CurrentAccount.current_account(conn) == nil
    end
  end

end
