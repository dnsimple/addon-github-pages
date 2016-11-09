defmodule GithubPagesConnector.GithubDummyAgent do
  use DummyAgent

  def oauth_authorize_url(state: _state) do
    "https://test.github.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
     {:ok, "github_account_id", "github_account_login", "github_access_token"}
  end

  def list_all_repositories(_account) do
    {:ok , [%{"name" => "user.github.io"}, %{"name" => "org.github.io"}, %{"name" => "project"}]}
  end

  def get_file(_account, _repository, _path) do
    {:ok, %{content: "content", sha: "sha"}}
  end

  def create_file(_account, repository, path, _content, _commit_message) do
    {:ok, _commit = %{"repository" => repository, "path" => path, "content" => %{"sha" => "sha"}}}
  end

  def update_file(_account, repository, path, _new_content, _current_sha, _commit_message) do
    {:ok, _commit = %{"repository" => repository, "path" => path, "content" => %{"sha" => "sha"}}}
  end

  def delete_file(_account, _repository, _path, _current_sha, _commit_message) do
    {:ok, _commit = %{}}
  end

end
