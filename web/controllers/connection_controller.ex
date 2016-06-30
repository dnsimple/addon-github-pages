defmodule GithubPagesConnector.ConnectionController do
  use GithubPagesConnector.Web, :controller

  alias GithubPagesConnector.Dnsimple
  alias GithubPagesConnector.MemoryRepo

  def new(conn, _params) do
    account_id = 63
    account    = MemoryRepo.get(account_id)

    {:ok, domains} = Dnsimple.list_all_domains(account)

    render(conn, "new.html", [
      domains: domains,
      dnsimple_account_id: account.dnsimple_account_id,
      dnsimple_access_token: account.dnsimple_access_token,
      github_access_token: account.github_access_token,
    ])
  end

  def create(conn, params) do
    text(conn, "creating connection for domain `#{params["domain"]}`...")
  end

end
