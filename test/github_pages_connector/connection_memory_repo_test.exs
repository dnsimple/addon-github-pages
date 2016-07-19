defmodule GithubPagesConnector.ConnectionMemoryRepoTest do
  use ExUnit.Case, async: true
  alias GithubPagesConnector.Connection
  alias GithubPagesConnector.ConnectionMemoryRepo

  @connection %Connection{}
  @repo ConnectionMemoryRepo

  describe "get" do
    test "returns the connection stored under given key" do
      connection = @repo.put(@connection)

      connection = @repo.get(connection.id)
      refute connection == nil
      assert connection.__struct__ == Connection
    end

    test "returns nil if no connection was stored under given key" do
      assert @repo.get(:other_id) == nil
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
      assert connection.__struct__ == Connection
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
    @connection1 @repo.put(%Connection{account_id: "1"})
    @connection2 @repo.put(%Connection{account_id: "2"})
    @connection3 @repo.put(%Connection{account_id: "2"})

    test "returns connections with given account_id" do
      assert @repo.list_connections("1") == [@connection1]
      assert Enum.sort(@repo.list_connections("2")) == Enum.sort([@connection2, @connection3])
    end

    test "returns an empty list if there is no connection for given account_id" do
      assert @repo.list_connections("0") == []
    end
  end

end
