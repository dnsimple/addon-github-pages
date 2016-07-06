defmodule GithubPagesConnector.GithubTest do
  use ExUnit.Case

  alias GithubPagesConnector.Github

  describe ".oauth_authorize_url" do
    test "generates the OAuth dance url" do
      expected_url = "https://github.com/login/oauth/authorize?client_id=26bdee190f3d6af8f9e3&redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fgithub%2Fcallback&response_type=code"
      assert Github.oauth_authorize_url(state: "abcd") == expected_url
    end
  end

end
