defmodule GithubPagesConnector.DnsimpleOauthController do
  use GithubPagesConnector.Web, :controller

  @base_url "https://api.sandbox.dnsimple.com"
  @state "12345678"
  @client_id "14633962cac66aed"
  @client_secret "vMFp5bDYJ1ngEzLg6rHD9pwrTmo7sCDD"

  def new(conn, _params) do
    client    = %Dnsimple.Client{base_url: @base_url}
    oauth_url = Dnsimple.OauthService.authorize_url(client, @client_id, state: @state)
    redirect(conn, external: oauth_url)
  end

  def create(conn, params) do
    client     = %Dnsimple.Client{base_url: @base_url}
    attributes = %{
      client_id: @client_id,
      client_secret: @client_secret,
      code: params["code"],
      state: params["state"]
    }
    case Dnsimple.OauthService.exchange_authorization_for_token(client, attributes) do
      {:ok, response} ->
        redirect(conn, to: github_oauth_path(conn, :new))
      {:error, error} ->
        IO.inspect(error)
        raise "OAuth authentication failed: #{inspect(error)}"
    end
  end

end
