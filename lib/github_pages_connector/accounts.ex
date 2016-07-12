defmodule GithubPagesConnector.Accounts do
  alias GithubPagesConnector.Account

  @repo GithubPagesConnector.MemoryRepo

  def signup_account(account_data = [dnsimple_account_id: dnsimple_account_id,
                                     dnsimple_account_email: dnsimple_account_email,
                                     dnsimple_access_token: dnsimple_access_token]) do
    account = struct(Account, account_data)
    @repo.put(dnsimple_account_id, account)
    account
  end

end
