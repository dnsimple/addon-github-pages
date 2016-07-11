defmodule GithubPagesConnector.GithubOauthControllerTest do
  use GithubPagesConnector.ConnCase

  describe ".new" do
    test "starts the GitHub OAuth dance", %{conn: conn} do
      conn = get conn, github_oauth_path(conn, :new)
      assert redirected_to(conn) =~ "https://test.github.com/auth/authorize?client_id=client_id&state=state"
    end
  end

end
