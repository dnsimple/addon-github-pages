defmodule GithubPagesConnector.GithubOauthController do
  use GithubPagesConnector.Web, :controller

  plug GithubPagesConnector.Plug.CurrentAccount

  @accounts GithubPagesConnector.Services.Accounts
  @github Application.get_env(:github_pages_connector, :github)
  @state "12345678"

  def new(conn, _params) do
    redirect(conn, external: @github.oauth_authorize_url(state: @state))
  end

  def create(conn, params) do
    case @github.oauth_authorization(code: params["code"], state: @state) do
      {:ok, github_account_id, github_account_login, github_access_token} ->
        @accounts.connect_github(conn.assigns[:current_account], [
          github_account_id: github_account_id,
          github_account_login: github_account_login,
          github_access_token: github_access_token,
        ])
        redirect(conn, to: connection_path(conn, :index))
      {:error, error} ->
        raise "GitHub OAuth authentication failed: #{inspect(error)}"
    end
  end

end
