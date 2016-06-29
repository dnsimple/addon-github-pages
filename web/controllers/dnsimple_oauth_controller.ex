defmodule GithubPagesConnector.DnsimpleOauthController do
  use GithubPagesConnector.Web, :controller

  @dnsimple Application.get_env :github_pages_connector, :dnsimple
  @state "12345678"

  @base_url "https://api.sandbox.dnsimple.com"
  @client_id "14633962cac66aed"
  @client_secret "vMFp5bDYJ1ngEzLg6rHD9pwrTmo7sCDD"

  def new(conn, _params) do
    oauth_url = @dnsimple.oauth_authorize_url(state: @state)
    redirect(conn, external: oauth_url)
  end

  def create(conn, params) do
    case @dnsimple.oauth_authorization(code: params["code"], state: @state) do
      {:ok, account_id, access_token} ->
        new_conn = put_session(conn, :dnsimple_account_id, account_id)
        new_conn = put_session(new_conn, :dnsimple_access_token, access_token)
        redirect(new_conn, to: github_oauth_path(new_conn, :new))
      {:error, error} ->
        IO.inspect(error)
        raise "OAuth authentication failed: #{inspect(error)}"
    end
  end

end
