defmodule GithubPagesConnector.ConnectionController do
  use GithubPagesConnector.Web, :controller

  plug GithubPagesConnector.Plug.CurrentAccount

  alias GithubPagesConnector.Dnsimple
  alias GithubPagesConnector.MemoryRepo


  def new(conn, _params) do
    account    = conn.assigns[:current_account]

    {:ok, domains} = Dnsimple.list_all_domains(account)

    render(conn, "new.html", [
      domains: domains,
      dnsimple_account_id: account.dnsimple_account_id,
      dnsimple_access_token: account.dnsimple_access_token,
      github_access_token: account.github_access_token,
    ])
  end

  def create(conn, params) do
    account    = conn.assigns[:current_account]

    {:ok, record} = Dnsimple.create_record(account, params["domain"], %{name: "", type: "ALIAS", content: "jacegu.github.io"})

    text(conn, "creating connection for domain `#{params["domain"]}`...")
  end

end
