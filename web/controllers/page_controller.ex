defmodule GithubPagesConnector.PageController do
  use GithubPagesConnector.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
