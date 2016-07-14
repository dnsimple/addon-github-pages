defmodule GithubPagesConnector.Connection do
  use GithubPagesConnector.Web, :model

  schema "connections" do
    field :dnsimple_account_id, :string
    field :dnsimple_domain, :string
    field :dnsimple_record_ids, {:array, :integer}
    field :github_repository, :string

    timestamps
  end

end
