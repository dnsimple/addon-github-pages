defmodule GithubPagesConnector.ConnectionView do
  use GithubPagesConnector.Web, :view

  def repository_names(repositories) do
    repositories
    |> Enum.map(&(Map.get(&1, "name")))
    |> Enum.map(&String.downcase/1)
    |> Enum.sort
  end

  def domain_names(domains) do
    domains
    |> Enum.map(&(Map.get(&1, :name)))
    |> Enum.sort
  end

end
