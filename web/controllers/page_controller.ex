defmodule GithubPagesConnector.PageController do
  use GithubPagesConnector.Web, :controller

  plug GithubPagesConnector.Plug.CurrentAccount, require_authentication: false

  def index(conn, _params) do
    case conn.assigns[:current_account] do
      nil      -> render(conn, "index.html")
      _account -> redirect(conn, to: connection_path(conn, :index))
    end
  end

  def login(conn, _params) do
    case conn.assigns[:current_account] do
      nil      -> redirect(conn, to: dnsimple_oauth_path(conn, :new))
      _account -> redirect(conn, to: connection_path(conn, :index))
    end
  end

  def logout(conn, _params) do
    conn
    |> GithubPagesConnector.Plug.CurrentAccount.disconnect
    |> redirect(to: page_path(conn, :index))
  end

end
