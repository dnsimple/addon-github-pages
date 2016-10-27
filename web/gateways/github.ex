defmodule GithubPagesConnector.Gateways.Github do
  alias GithubPagesConnector.Account

  @oauth_scope "repo"
  @oauth_client OAuth2.Client.new([
    client_id: Application.fetch_env!(:github_pages_connector, :github_client_id),
    client_secret: Application.fetch_env!(:github_pages_connector, :github_client_secret),
    token_url: Application.fetch_env!(:github_pages_connector, :github_token_uri),
    redirect_uri: Application.fetch_env!(:github_pages_connector, :github_redirect_uri),
    authorize_url: Application.fetch_env!(:github_pages_connector, :github_authorize_uri),
  ])

  def oauth_authorize_url(state: _state) do
    @oauth_client
    |> OAuth2.Client.put_param(:scope, @oauth_scope)
    |> OAuth2.Client.authorize_url!
  end

  def oauth_authorization(code: code, state: state) do
    try do
      access_token = access_token(code, state)
      {account_id, account_login} = account_data(access_token)
      {:ok, account_id, account_login, access_token}
    rescue error ->
      {:error , error}
    end
  end

  def list_all_repositories(account) do
    try do
      repositories = Tentacat.Repositories.list_mine(client(account))
      {:ok, repositories}
    rescue error ->
      {:error , error}
    end
  end

  def get_file(account, repository, path) do
    owner = account.github_account_login

    try do
      case Tentacat.Contents.find(owner, repository, path, client(account)) do
        {404, _} ->
          {:error, :notfound}
        file ->
          content = Base.decode64!(file["content"], ignore: :whitespace)
          {:ok, %{content: content, sha: file["sha"]}}
      end
    rescue error ->
      {:error , error}
    end
  end

  def create_file(account, repository, path, content, commit_message) do
    owner = account.github_account_login
    body  = %{content: Base.encode64(content), message: commit_message}

    try do
      {201, commit} = Tentacat.Contents.create(owner, repository, path, body, client(account))
      {:ok, commit}
    rescue error ->
      {:error , error}
    end
  end

  def update_file(account, repository, path, new_content, current_sha, commit_message) do
    owner = account.github_account_login
    body  = %{content: Base.encode64(new_content), message: commit_message, sha: current_sha}

    try do
      commit = Tentacat.Contents.update(owner, repository, path, body, client(account))
      {:ok, commit}
    rescue error ->
      {:error , error}
    end
  end

  def delete_file(account, repository, path, sha, commit_message) do
    owner = account.github_account_login
    body  = %{message: commit_message, sha: sha}

    try do
      commit = Tentacat.Contents.remove(owner, repository, path, body, client(account))
      {:ok, commit}
    rescue error ->
      {:error , error}
    end
  end

  defp access_token(code, _state) do
    @oauth_client
    |> OAuth2.Client.get_token!(code: code)
    |> Map.get(:access_token)
  end

  defp account_data(access_token) do
    data = Tentacat.Users.me(client(access_token))

    {data["id"], data["login"]}
  end

  defp client(%Account{github_access_token: access_token}), do: client(access_token)
  defp client(access_token), do: Tentacat.Client.new(%{access_token: access_token})

end
