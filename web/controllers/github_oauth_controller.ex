defmodule GithubPagesConnector.GithubOauthController do
  use GithubPagesConnector.Web, :controller

  @client_id "26bdee190f3d6af8f9e3"
  @client_secret "a5f8fb3be0467f30a34f0f574c2c7cd9877463a5"

  @client OAuth2.Client.new([
    client_id: @client_id,
    client_secret: @client_secret,
    site: "https://api.github.com",
    token_url: "https://github.com/login/oauth/access_token",
    authorize_url: "https://github.com/login/oauth/authorize",
    redirect_uri: "http://localhost:4000/github/callback",
  ])

  def new(conn, _params) do
    redirect(conn, external: OAuth2.Client.authorize_url!(@client))
  end

  def create(conn, params) do
    token = OAuth2.Client.get_token!(@client, code: params["code"])
    render(conn, "welcome.html", dnsimple_token: "", github_token: token)
  end

end
