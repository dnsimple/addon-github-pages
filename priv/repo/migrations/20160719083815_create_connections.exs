defmodule GithubPagesConnector.Repo.Migrations.CreateConnections do
  use Ecto.Migration

  def change do
    create table(:connections) do
      add :account_id, references(:accounts)
      add :dnsimple_domain, :string
      add :dnsimple_record_id, :integer
      add :github_repository, :string
      add :github_file_sha, :string

      timestamps
    end
  end
end
