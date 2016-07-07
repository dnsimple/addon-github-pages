defmodule GithubPagesConnector.Github do
  alias GithubPagesConnector.Account

  @oauth_scope "repo"
  @oauth_client OAuth2.Client.new([
    client_id: Application.get_env(:github_pages_connector, :github_client_id),
    client_secret: Application.get_env(:github_pages_connector, :github_client_secret),
    token_url: Application.get_env(:github_pages_connector, :github_token_uri),
    redirect_uri: Application.get_env(:github_pages_connector, :github_redirect_uri),
    authorize_url: Application.get_env(:github_pages_connector, :github_authorize_uri),
  ])

  def oauth_authorize_url(state: state) do
    @oauth_client
    |> OAuth2.Client.put_param(:scope, @oauth_scope)
    |> OAuth2.Client.authorize_url!
  end

  def oauth_authorization(code: code, state: state) do
    access_token = access_token(code, state)
    {:ok, user_login(access_token), access_token}
  end

  def list_all_repositories(account) do
    try do
      repositories = Tentacat.Repositories.list_mine(client(account))
      {:ok, repositories}
    rescue error -> error
      {:error , error}
    end
  end


  defp access_token(code, state) do
    @oauth_client
    |> OAuth2.Client.get_token!(code: code)
    |> Map.get(:access_token)
  end

  defp user_login(access_token) do
    client(access_token)
    |> Tentacat.Users.me
    |> Map.get("login")
  end

  defp client, do: client(nil)
  defp client(%Account{github_access_token: access_token}), do: client(access_token)
  defp client(access_token), do: Tentacat.Client.new(%{access_token: access_token})

end
