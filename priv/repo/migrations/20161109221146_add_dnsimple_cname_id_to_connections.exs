defmodule GithubPagesConnector.Repo.Migrations.AddDnsimpleCnameIdToConnections do
  use Ecto.Migration

  def change do
    alter table(:connections) do
      add :dnsimple_alias_id, :integer
      add :dnsimple_cname_id, :integer
      remove :dnsimple_record_id
    end
  end
end
