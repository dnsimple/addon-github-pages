defmodule GithubPagesConnector.OauthController do
  use GithubPagesConnector.Web, :controller

  @base_url "api.sandbox.dnsimple.com"
  @state "12345678"
  @client_id "3748375270ba39d9"
  @client_secret "kJLFFaRnLnqF2pYyancND3sWMfQWmtAY"

  def new(conn, _params) do
    client    = %Dnsimple.Client{}
    oauth_url = Dnsimple.OauthService.authorize_url(client, @client_id, state: @state)
    redirect(conn, external: oauth_url)
  end

  def create(conn, params) do
    client = %Dnsimple.Client{}
    attributes = %{
      client_id: @client_id,
      client_secret: @client_secret,
      code: params["code"],
      state: params["state"]
    }
    case Dnsimple.OauthService.exchange_authorization_for_token(client, attributes) do
      {:ok, response} ->
        render conn, "welcome.html", access_token: response.data
      {:error, error} ->
        IO.inspect(error)
        raise "OAuth authentication failed: #{inspect(error)}"
    end
  end

end
