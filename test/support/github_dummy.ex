defmodule GithubPagesConnector.GithubDummy do

  def oauth_authorize_url(state: _state) do
    "https://test.github.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization do
  end

end
