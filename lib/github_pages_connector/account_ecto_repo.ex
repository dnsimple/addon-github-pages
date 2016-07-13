defmodule GithubPagesConnector.AccountEctoRepo do
  alias GithubPagesConnector.Repo
  alias GithubPagesConnector.Account
  alias Ecto.Changeset

  @attributes [
    :dnsimple_account_id,
    :dnsimple_account_email,
    :dnsimple_access_token,
    :github_account_id,
    :github_account_login,
    :github_access_token,
  ]

  def get(dnsimple_account_id) do
    Repo.get_by(Account, dnsimple_account_id: to_string(dnsimple_account_id))
  end

  def put(account) do
    case get(account.dnsimple_account_id) do
      nil     -> insert(account)
      account -> update(account)
    end
  end


  defp insert(account) do
    params = Map.take(account, @attributes)

    account
    |> Changeset.cast(params, @attributes)
    |> Repo.insert!
  end

  defp update(account) do
    params = Map.take(account, @attributes)

    account
    |> Changeset.cast(params, @attributes)
    |> Repo.update!
  end

end
