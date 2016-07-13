defmodule GithubPagesConnector.Accounts do
  alias GithubPagesConnector.Account

  @repo GithubPagesConnector.AccountEctoRepo

  def get_account(dnsimple_account_id) do
    @repo.get(dnsimple_account_id)
  end

  def signup_account(dnsimple_account_data) do
    struct(Account, dnsimple_account_data)
    |> @repo.put
  end

  def connect_github(dnsimple_account_id, github_account_data) do
    github_account_data = Enum.into(github_account_data, %{})

    get_account(dnsimple_account_id)
    |> Map.merge(github_account_data)
    |> @repo.put
  end

end
