defmodule GithubPagesConnector.PageControllerTest do
  use GithubPagesConnector.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "DNSimple"
  end
end
