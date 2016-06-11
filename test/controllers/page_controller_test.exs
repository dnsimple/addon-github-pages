defmodule GithubPagesConnector.PageControllerTest do
  use GithubPagesConnector.ConnCase, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(GithubPagesConnector.Repo)
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
