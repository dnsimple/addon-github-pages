defmodule GithubPagesConnector.AccountEctoRepo do
  alias GithubPagesConnector.Repo
  alias GithubPagesConnector.Account

  def get(dnsimple_account_id) do
    Repo.get_by(Account, dnsimple_account_id: to_string(dnsimple_account_id))
  end

  def put(account) do
    case get(account.dnsimple_account_id) do
      nil         -> insert(account)
      old_account -> update(old_account, account)
    end
  end


  defp insert(account) do
    Account.changeset(account, account)
    |> Repo.insert!
  end

  defp update(account, updated_account) do
    Account.changeset(account, updated_account)
    |> Repo.update!
  end

end
