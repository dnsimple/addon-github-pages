defmodule GithubPagesConnector.Plug.CurrentAccount do
  import Plug.Conn
  require Logger

  @accounts GithubPagesConnector.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case current_account(conn) do
      nil ->
        conn
        |> Phoenix.Controller.redirect(to: GithubPagesConnector.Router.Helpers.dnsimple_oauth_path(conn, :new))
        |> halt
      account ->
        assign(conn, :current_account, account)
    end
  end

  def current_account(conn) do
    case conn.assigns[:current_account_id] do
      nil        -> fetch_account(conn)
      account_id -> @accounts.get_account(account_id)
    end
  end

  def account_connected?(conn), do: current_account(conn) != nil

  def disconnect(conn), do: delete_session(conn, :current_account_id)

  defp fetch_account(conn) do
    case get_session(conn, :current_account_id) do
      nil        -> nil
      account_id -> @accounts.get_account(account_id)
    end
  end
end
