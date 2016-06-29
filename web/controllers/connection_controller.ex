defmodule GithubPagesConnector.ConnectionController do
  use GithubPagesConnector.Web, :controller

  alias GithubPagesConnector.Dnsimple
  alias GithubPagesConnector.MemoryRepo

  def new(conn, _params) do
    account_id = 63
    account    = MemoryRepo.get(account_id)

    render(conn, "new.html", [
      dnsimple_account_id: account.dnsimple_account_id,
      dnsimple_access_token: account.dnsimple_access_token,
      github_access_token: account.github_access_token,
    ])
  end
end
