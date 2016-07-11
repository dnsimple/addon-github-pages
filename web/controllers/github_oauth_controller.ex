defmodule GithubPagesConnector.GithubOauthController do
  use GithubPagesConnector.Web, :controller
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.MemoryRepo

  @github Application.get_env(:github_pages_connector, :github)
  @state "12345678"

  def new(conn, _params) do
    url = @github.oauth_authorize_url(state: @state)
    redirect(conn, external: url)
  end

  def create(conn, params) do
    case @github.oauth_authorization(code: params["code"], state: @state) do
      {:ok, github_user_login, github_access_token} ->
        dnsimple_account_id   = get_session(conn, :dnsimple_account_id)
        dnsimple_access_token = get_session(conn, :dnsimple_access_token)

        MemoryRepo.put(dnsimple_account_id, %Account{
          dnsimple_account_id: dnsimple_account_id,
          dnsimple_access_token: dnsimple_access_token,
          github_user_login: github_user_login,
          github_access_token: github_access_token,
        })

        conn
        |> put_session(:account_id, dnsimple_account_id)
        |> redirect(to: connection_path(conn, :new))
      {:error, error} ->
        IO.inspect(error)
        raise "OAuth authentication failed: #{inspect(error)}"
    end
  end

end
