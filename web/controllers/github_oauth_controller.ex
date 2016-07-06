defmodule GithubPagesConnector.GithubOauthController do
  use GithubPagesConnector.Web, :controller
  alias GithubPagesConnector.Github
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.MemoryRepo

  def new(conn, _params) do
    redirect(conn, external: Github.oauth_authorize_url(state: "12345678"))
  end

  def create(conn, params) do
    dnsimple_account_id   = get_session(conn, :dnsimple_account_id)
    dnsimple_access_token = get_session(conn, :dnsimple_access_token)
    github_access_token   = Github.oauth_authorization(code: params["code"], state: "12345678")

    MemoryRepo.put(dnsimple_account_id, %Account{
      dnsimple_account_id: dnsimple_account_id,
      dnsimple_access_token: dnsimple_access_token,
      github_access_token: github_access_token,
    })

    conn
    |> put_session(:account_id, dnsimple_account_id)
    |> redirect(to: connection_path(conn, :new))
  end

end
