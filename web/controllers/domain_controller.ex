defmodule GithubPagesConnector.DomainController do
  use GithubPagesConnector.Web, :controller

  @connections GithubPagesConnector.Services.Connections

  plug GithubPagesConnector.Plug.CurrentAccount

  def index(conn, _params) do
    account = conn.assigns[:current_account]
    domains = @connections.list_domains(account) |> Enum.map(&(&1.name))
    json conn, %{domains: domains}
  end

end
