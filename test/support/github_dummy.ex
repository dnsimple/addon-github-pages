defmodule GithubPagesConnector.GithubDummy do

  def oauth_authorize_url(state: _state) do
    "https://test.github.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
     {:ok, "github_account_id", "github_account_login", "github_access_token"}
  end

  def list_all_repositories(_account) do
    {:ok , [%{"name" => "repo1"}, %{"name" => "repo2"}, %{"name" => "repo3"}]}
  end

end
