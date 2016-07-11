defmodule GithubPagesConnector.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :dnsimple_account_id, :string
      add :dnsimple_account_email, :string
      add :dnsimple_access_token, :string

      add :github_account_id, :string
      add :github_account_login, :string
      add :github_access_token, :string

      timestamps
    end
    create index(:accounts, [:dnsimple_account_id])
    create index(:accounts, [:github_account_id])
  end
end
