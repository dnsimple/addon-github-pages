defmodule GithubPagesConnector.ConnectionEctoRepoTest do
  use ExUnit.Case, async: true

  @repo GithubPagesConnector.ConnectionEctoRepo
  @connection %GithubPagesConnector.Connection{
    dnsimple_domain: "dnsimple_domain",
    dnsimple_record_id: 12345,
    github_repository: "github_repository",
    github_file_sha: "xXxXxX",
  }

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(GithubPagesConnector.Repo)
  end

  describe "get" do
    test "returns the connection stored under given key" do
      connection = @repo.put(@connection)

      connection = @repo.get(connection.id)
      refute connection == nil
      assert connection.__struct__ == GithubPagesConnector.Connection
    end

    test "returns nil if no connection was stored under given key" do
      assert @repo.get(345) == nil
    end
  end

  describe "put" do
    test "assigns an id to the connection" do
      connection = @repo.put(@connection)

      refute connection.id == nil
    end

    test "stores the connection under the connection's id" do
      connection = @repo.put(@connection)

      connection = @repo.get(connection.id)
      refute connection == nil
      assert connection.__struct__ == GithubPagesConnector.Connection
    end

    test "overwrites the connection if another connection with the same id exists" do
      connection = @connection
      |> @repo.put
      |> Map.put(:dnsimple_domain, "other_domain")
      |> @repo.put

      connection = @repo.get(connection.id)
      assert connection.dnsimple_domain == "other_domain"
    end
  end

  describe ".remove" do
    test "removes the connection" do
      connection = @repo.put(@connection)

      @repo.remove(connection)

      connection = @repo.get(connection.id)
      assert connection == nil
    end

    test "returns the removed connection" do
      connection = @repo.put(@connection)

      connection = @repo.remove(connection)
      assert connection.__struct__ == GithubPagesConnector.Connection
    end
  end

  describe ".list_connections" do
    test "returns connections with given account_id" do
      account1    = GithubPagesConnector.Repo.insert!(%GithubPagesConnector.Account{})
      account2    = GithubPagesConnector.Repo.insert!(%GithubPagesConnector.Account{})
      connection1 = @repo.put(%GithubPagesConnector.Connection{account_id: account1.id})
      connection2 = @repo.put(%GithubPagesConnector.Connection{account_id: account2.id})
      connection3 = @repo.put(%GithubPagesConnector.Connection{account_id: account2.id})

      assert @repo.list_connections(account1.id) == [connection1]
      assert @repo.list_connections(account2.id) == [connection2, connection3]
    end

    test "returns an empty list if there is no connection for given account_id" do
      assert @repo.list_connections("0") == []
    end
  end

end
