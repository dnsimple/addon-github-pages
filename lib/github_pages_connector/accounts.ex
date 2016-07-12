defmodule GithubPagesConnector.Accounts do
  alias GithubPagesConnector.Account

  @repo GithubPagesConnector.MemoryRepo

  def signup_account(dnsimple_data = [dnsimple_account_id: dnsimple_account_id,
                                      dnsimple_account_email: dnsimple_account_email,
                                      dnsimple_access_token: dnsimple_access_token]) do
    account = struct(Account, dnsimple_data)
    @repo.put(dnsimple_account_id, account)
    account
  end

  def connect_github(account_id, github_data = [github_account_id: github_account_id,
                                                github_account_login: github_account_login,
                                                github_access_token: github_access_token]) do
    data    = Enum.into(github_data, %{})
    account = @repo.get(account_id) |> Map.merge(data)
    @repo.put(account_id, account)
    account
  end

end
