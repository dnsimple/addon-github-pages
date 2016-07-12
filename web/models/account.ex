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

end
