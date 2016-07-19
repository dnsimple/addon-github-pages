defmodule GithubPagesConnector.Connection do
  use GithubPagesConnector.Web, :model

  schema "connections" do
    field :account_id, :integer
    field :dnsimple_domain, :string
    field :dnsimple_record_id, :integer
    field :github_repository, :string
    field :github_file_sha, :string

    timestamps
  end

end
