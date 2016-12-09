defmodule GithubPagesConnector.Connection do
  use GithubPagesConnector.Web, :model

  schema "connections" do
    field :account_id, :integer
    field :dnsimple_domain, :string
    field :dnsimple_alias_id, :integer
    field :dnsimple_cname_id, :integer
    field :github_repository, :string
    field :github_file_sha, :string

    timestamps
  end

  @attributes [
    :account_id,
    :dnsimple_domain,
    :dnsimple_alias_id,
    :dnsimple_cname_id,
    :github_repository,
    :github_file_sha,
  ]

  def upsert_changeset(connection, connection_with_changes) do
    cast(connection, changes(connection_with_changes), @attributes)
  end

  def attribute_changeset(connection, attribute_name, attribute_value) do
    cast(connection, %{attribute_name => attribute_value}, [attribute_name])
  end

  defp changes(connection) do
    Map.take(connection, @attributes)
  end

end
