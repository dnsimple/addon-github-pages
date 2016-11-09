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
    get_stubbed_value(:get_file, {:ok, %{content: "content", sha: "sha"}})
  end

  def create_file(account, repository, path, content, commit_message) do
    record_call(:create_file, [account, repository, path, content, commit_message])
    {:ok, get_stubbed_value(:create_record, _commit = %{"repository" => repository, "path" => path, "content" => %{"sha" => "sha"}})}
  end

  def update_file(_account, repository, path, _new_content, _current_sha, _commit_message) do
    {:ok, _commit = %{"repository" => repository, "path" => path, "content" => %{"sha" => "sha"}}}
  end

  def delete_file(account, repository, path, current_sha, commit_message) do
    record_call(:delete_file, [account, repository, path, current_sha, commit_message])
    {:ok, get_stubbed_value(:create_record, _commit = %{})}
  end

end
