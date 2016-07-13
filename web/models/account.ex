defmodule GithubPagesConnector.Account do
  use GithubPagesConnector.Web, :model

  schema "accounts" do
    field :dnsimple_account_id, :string
    field :dnsimple_account_email, :string
    field :dnsimple_access_token, :string
    field :github_account_id, :string
    field :github_account_login, :string
    field :github_access_token, :string

    timestamps
  end

  @attributes [
    :dnsimple_account_id,
    :dnsimple_account_email,
    :dnsimple_access_token,
    :github_account_id,
    :github_account_login,
    :github_access_token,
  ]

  def changeset(account, account_with_changes) do
    cast(account, changes(account_with_changes), @attributes)
  end

  defp changes(account) do
    account
    |> Map.take(@attributes)
    |> Map.new(fn({key, value}) -> {key, to_string(value)} end)
  end

end
