defmodule GithubPagesConnector.Plug.CurrentAccount do
  import Plug.Conn
  require Logger

  @repo GithubPagesConnector.MemoryRepo

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
    case conn.assigns[:current_account] do
      nil     -> fetch_account(conn)
      account -> account
    end
  end

  def disconnect(conn), do: delete_session(conn, :account_id)

  defp fetch_account(conn) do
    case get_session(conn, :account_id) do
      nil        -> nil
      account_id -> @repo.get(account_id)
    end
  end
end
