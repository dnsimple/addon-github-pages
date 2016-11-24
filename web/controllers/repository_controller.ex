defmodule GithubPagesConnector.RepositoryController do
  use GithubPagesConnector.Web, :controller

  @connections GithubPagesConnector.Services.Connections

  plug GithubPagesConnector.Plug.CurrentAccount

  def index(conn, _params) do
    account      = conn.assigns[:current_account]
    repositories = @connections.list_pages_repositories(account) |> Enum.map(&(&1["name"]))
    json conn, %{repositories: repositories}
  end

end
