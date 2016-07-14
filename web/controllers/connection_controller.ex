defmodule GithubPagesConnector.ConnectionController do
  use GithubPagesConnector.Web, :controller
  alias GithubPagesConnector.Github
  alias GithubPagesConnector.Dnsimple

  @connections GithubPagesConnector.Connections

  plug GithubPagesConnector.Plug.CurrentAccount

  def index(conn, _params) do
    account = conn.assigns[:current_account]

    case @connections.list_connections(account) do
      []          -> redirect(conn, to: connection_path(conn, :new))
      connections -> render(conn, "index.html", connections: connections)
    end
  end

  def new(conn, _params) do
    account = conn.assigns[:current_account]

    {:ok, repositories} = Github.list_all_repositories(account)
    {:ok, domains}      = Dnsimple.list_all_domains(account)

    render(conn, "new.html", repositories: repositories, domains: domains)
  end

  def create(conn, params) do
    account    = conn.assigns[:current_account]

    domain     = params["domain"]
    repository = params["repository"]

    client     = Tentacat.Client.new(%{access_token: account.github_access_token})
    user       = Tentacat.Users.me(client)

    owner      = user["login"]
    path       = "CNAME"
    body       = %{content: Base.encode64(domain), message: "Configure #{domain} with DNSimple"}

    response = Tentacat.Contents.find(owner, repository, "README.md", client)
    IO.inspect(response)

    IO.puts ""
    IO.inspect owner
    IO.inspect repository
    IO.inspect path
    IO.inspect body
    IO.puts ""

    response = Tentacat.Contents.create(owner, repository, path, body, client)
    IO.inspect(response)

    {:ok, record} = Dnsimple.create_record(account, domain, %{name: "", type: "ALIAS", content: "jacegu.github.io"})

    text(conn, "creating connection for domain `#{params["domain"]}`...")
  end

end
