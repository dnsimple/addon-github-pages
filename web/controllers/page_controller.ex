defmodule GithubPagesConnector.PageController do
  use GithubPagesConnector.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def login(conn, _params) do
    case conn.assigns[:current_account] do
      nil      -> redirect(conn, to: dnsimple_oauth_path(conn, :new))
      _account -> redirect(conn, to: connection_path(conn, :new))
    end
  end

  def logout(conn, _params) do
    conn
    |> GithubPagesConnector.Plug.CurrentAccount.disconnect
    |> redirect(to: page_path(conn, :index))
  end

end
