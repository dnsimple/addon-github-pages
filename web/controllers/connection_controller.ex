defmodule GithubPagesConnector.ConnectionController do
  use GithubPagesConnector.Web, :controller

  @github Application.get_env(:github_pages_connector, :github)
  @dnsimple Application.get_env(:github_pages_connector, :dnsimple)
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

    {:ok, repositories} = @github.list_all_repositories(account)
    {:ok, domains}      = @dnsimple.list_all_domains(account)

    render(conn, "new.html", repositories: repositories, domains: domains)
  end

  def create(conn, params) do
    account    = conn.assigns[:current_account]
    domain     = params["domain"]
    repository = params["repository"]

    @connections.new_connection(account, dnsimple_domain: domain, github_repository: repository)

    conn
    |> put_flash(:info, "#{domain} now points to GitHub pages #{repository}")
    |> redirect(to: connection_path(conn, :index))
  end

  def delete(conn, params) do
    connection = @connections.remove_connection(conn.assigns[:current_account], params["id"])
    message    = "Connection for #{connection.dnsimple_domain} to #{connection.github_repository} removed"

    conn
    |> put_flash(:info, message)
    |> redirect(to: connection_path(conn, :index))
  end

end
