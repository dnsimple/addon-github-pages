defmodule GithubPagesConnector.DnsimpleOauthController do
  use GithubPagesConnector.Web, :controller

  @accounts GithubPagesConnector.Accounts
  @dnsimple Application.get_env :github_pages_connector, :dnsimple
  @state "12345678"

  def new(conn, _params) do
    oauth_url = @dnsimple.oauth_authorize_url(state: @state)
    redirect(conn, external: oauth_url)
  end

  def create(conn, params) do
    case @dnsimple.oauth_authorization(code: params["code"], state: @state) do
      {:ok, account_id, account_email, access_token} ->
        @accounts.signup_account([
          dnsimple_account_id: account_id,
          dnsimple_account_email: account_email,
          dnsimple_access_token: access_token
        ])
        redirect(conn, to: github_oauth_path(conn, :new))
      {:error, error} ->
        IO.inspect(error)
        raise "OAuth authentication failed: #{inspect(error)}"
    end
  end

end
