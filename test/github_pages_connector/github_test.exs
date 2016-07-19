defmodule GithubPagesConnector.GithubTest do
  use ExUnit.Case, async: true

  alias GithubPagesConnector.Github

  describe ".oauth_authorize_url" do
    test "generates the OAuth dance url" do
      assert Github.oauth_authorize_url(state: "abcd") == "https://github.com/login/oauth/authorize?client_id=client_id&redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fgithub%2Fcallback&response_type=code&scope=repo"
    end
  end

end
