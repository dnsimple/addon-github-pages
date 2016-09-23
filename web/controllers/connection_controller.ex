defmodule GithubPagesConnector.ConnectionController do
  use GithubPagesConnector.Web, :controller

  @connections GithubPagesConnector.Services.Connections

  plug GithubPagesConnector.Plug.CurrentAccount

  def index(conn, _params) do
    account = conn.assigns[:current_account]

    case @connections.list_connections(account) do
      [] ->
        conn
        |> put_flash(:info, "You have no connections; go ahead and create one.")
        |> redirect(to: connection_path(conn, :new))
      connections ->
        render(conn, "index.html", connections: connections)
    end
  end

  def new(conn, _params) do
    account      = conn.assigns[:current_account]
    repositories = @connections.list_pages_repositories(account)
    domains      = @connections.list_domains(account)

    render(conn, "new.html", repositories: repositories, domains: domains)
  end

  def create(conn, params) do
    account    = conn.assigns[:current_account]
    domain     = params["domain"]
    repository = params["repository"]

    case @connections.new_connection(account, dnsimple_domain: domain, github_repository: repository) do
      {:ok, connection} ->
        conn
        |> put_flash(:info, "#{domain} now points to GitHub pages #{repository}")
        |> redirect(to: connection_path(conn, :index))
      {:ok, error} ->
        conn
        |> put_flash(:error, "Something went wrong: #{error.message}")
        |> redirect(to: connection_path(conn, :new))
    end
  end

  def delete(conn, params) do
    case @connections.remove_connection(conn.assigns[:current_account], params["id"]) do
      {:ok, connection} ->
        conn
        |> put_flash(:info, "Connection for #{connection.dnsimple_domain} to #{connection.github_repository} removed")
        |> redirect(to: connection_path(conn, :index))
      {:ok, error} ->
        conn
        |> put_flash(:error, "Something went wrong: #{error.message}")
        |> redirect(to: connection_path(conn, :index))
    end
  end

end
