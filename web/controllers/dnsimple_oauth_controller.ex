defmodule GithubPagesConnector.DnsimpleOauthController do
  use GithubPagesConnector.Web, :controller

  @dnsimple Application.get_env :github_pages_connector, :dnsimple
  @state "12345678"

  def new(conn, _params) do
    oauth_url = @dnsimple.oauth_authorize_url(state: @state)
    redirect(conn, external: oauth_url)
  end

  def create(conn, params) do
    case @dnsimple.oauth_authorization(code: params["code"], state: @state) do
      {:ok, account_id, access_token} ->
        conn
        |> put_session(:dnsimple_account_id, account_id)
        |> put_session(:dnsimple_access_token, access_token)
        |> redirect(to: github_oauth_path(conn, :new))
      {:error, error} ->
        IO.inspect(error)
        raise "OAuth authentication failed: #{inspect(error)}"
    end
  end

end
