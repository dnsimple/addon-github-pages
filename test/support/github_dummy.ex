defmodule GithubPagesConnector.GithubDummy do
  use DummyAgent

  def oauth_authorize_url(state: _state) do
    "https://test.github.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
     {:ok, "github_account_id", "github_account_login", "github_access_token"}
  end

  def list_all_repositories(account) do
    args = [account]
    record_call(:list_all_repositories, args)
    get_stubbed_value(:list_all_repositories, args, {:ok , [%{"name" => "user.github.io"}, %{"name" => "org.github.io"}, %{"name" => "project"}]})
  end

  def get_file(account, repository, path) do
    args = [account, repository, path]
    record_call(:get_file, args)
    get_stubbed_value(:get_file, args, {:ok, %{content: "content", sha: "sha"}})
  end

  def create_file(account, repository, path, content, commit_message) do
    args = [account, repository, path, content, commit_message]
    record_call(:create_file, args)
    get_stubbed_value(:create_file, args, {:ok, %{"repository" => repository, "path" => path, "content" => %{"sha" => "sha"}}})
  end

  def update_file(account, repository, path, new_content, current_sha, commit_message) do
    args = [account, repository, path, new_content, current_sha, commit_message]
    record_call(:update_file, args)
    get_stubbed_value(:update_file, args, {:ok, %{"repository" => repository, "path" => path, "content" => %{"sha" => "sha"}}})
  end

  def delete_file(account, repository, path, current_sha, commit_message) do
    args = [account, repository, path, current_sha, commit_message]
    record_call(:delete_file, args)
    get_stubbed_value(:delete_file, args, {:ok, %{}})
  end

end
