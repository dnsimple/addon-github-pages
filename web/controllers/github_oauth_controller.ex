defmodule GithubPagesConnector.GithubOauthController do
  use GithubPagesConnector.Web, :controller

  plug GithubPagesConnector.Plug.CurrentAccount

  @accounts GithubPagesConnector.Accounts
  @github Application.get_env(:github_pages_connector, :github)
  @state "12345678"

  def new(conn, _params) do
    url = @github.oauth_authorize_url(state: @state)
    redirect(conn, external: url)
  end

  def create(conn, params) do
    case @github.oauth_authorization(code: params["code"], state: @state) do
      {:ok, github_account_id, github_account_login, github_access_token} ->
        @accounts.connect_github(conn.assigns[:current_account_id], [
          github_account_id: github_account_id,
          github_account_login: github_account_login,
          github_access_token: github_access_token,
        ])
        redirect(conn, to: connection_path(conn, :new))
      {:error, error} ->
        raise "GitHub OAuth authentication failed: #{inspect(error)}"
    end
  end

end
