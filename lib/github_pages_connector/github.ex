defmodule GithubPagesConnector.Github do
  alias GithubPagesConnector.Account

  def list_all_repositories(account) do
    try do
      repositories = Tentacat.Repositories.list_mine(client(account))
      {:ok, repositories}
    rescue error -> error
      {:error , error}
    end
  end


  defp client, do: client(%Account{})
  defp client(%Account{github_access_token: access_token}) do
    Tentacat.Client.new(%{access_token: access_token})
  end

end
