defmodule GithubPagesConnector.OauthView do
  use GithubPagesConnector.Web, :view

  def token(access_token), do: access_token.access_token

end
