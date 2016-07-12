defmodule GithubPagesConnector.Accounts do
  alias GithubPagesConnector.Account

  @repo GithubPagesConnector.MemoryRepo

  def signup_account(dnsimple_account_id: dnsimple_account_id,
                     dnsimple_account_email: dnsimple_account_email,
                     dnsimple_access_token: dnsimple_access_token) do

    @repo.put(dnsimple_account_id, %Account{
      dnsimple_account_id: dnsimple_account_id,
      dnsimple_account_email: dnsimple_account_email,
      dnsimple_access_token: dnsimple_access_token
    })
  end

end
