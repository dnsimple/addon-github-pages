defmodule GithubPagesConnector.ConnectionsTest do
  use GithubPagesConnector.ConnCase

  alias GithubPagesConnector.Connection
  alias GithubPagesConnector.TransactionalPipeline

  @account_repo GithubPagesConnector.AccountEctoRepo
  @connection_repo GithubPagesConnector.ConnectionEctoRepo
  @connections GithubPagesConnector.Services.Connections
  @dnsimple GithubPagesConnector.DnsimpleDummy


  setup [:reset_dummies, :setup_account]

  describe ".add_alias_record" do
    setup [:setup_empty_connection]

    test "adds the alias record", %{connection: connection, account: account} do
      {:ok, _, _} = @connections._add_alias_record(connection, account)

      assert {:create_record, [account, "example.com", %{name: "", type: "ALIAS", content: "example.github.io"}]} in @dnsimple.calls
    end

    test "stores the record id in the connection", %{connection: connection, account: account} do
      {:ok, [connection, _], _} = @connections._add_alias_record(connection, account)

      stored_connection = @connection_repo.get(connection.id)
      refute connection.dnsimple_alias_id == nil
      refute stored_connection.dnsimple_alias_id == nil
      assert connection.dnsimple_alias_id == stored_connection.dnsimple_alias_id
    end

    test "returns the correct rollback function", %{connection: connection, account: account} do
      {:ok, [connection, _], rollback} = @connections._add_alias_record(connection, account)

      TransactionalPipeline.revert(rollback)

      stored_connection = @connection_repo.get(connection.id)
      assert stored_connection.dnsimple_alias_id == nil
      assert {:delete_record, [account, "example.com", connection.dnsimple_alias_id]} in @dnsimple.calls
    end
  end

  describe ".remove_alias_record" do
    setup context do
      {:ok, connection} = @connection_repo.put(%Connection{dnsimple_domain: "example.com", github_repository: "example.github.io", dnsimple_alias_id: 12345})
      Map.put(context, :connection, connection)
    end

    test "removes the alias record", %{connection: connection, account: account} do
      {:ok, _, _} = @connections._remove_alias_record(connection, account)

      assert {:delete_record, [account, "example.com", connection.dnsimple_alias_id]} in @dnsimple.calls
    end

    test "clears the record id in the connection", %{connection: connection, account: account} do
      {:ok, [connection, _], _} = @connections._remove_alias_record(connection, account)

      stored_connection = @connection_repo.get(connection.id)
      assert connection.dnsimple_alias_id == nil
      assert stored_connection.dnsimple_alias_id == nil
    end

    test "returns the correct rollback function", %{connection: connection, account: account} do
      {:ok, _, rollback} = @connections._remove_alias_record(connection, account)

      TransactionalPipeline.revert(rollback)

      stored_connection = @connection_repo.get(connection.id)
      refute stored_connection.dnsimple_alias_id == nil
      refute stored_connection.dnsimple_alias_id == connection.dnsimple_alias_id
      assert {:create_record, [account, "example.com", %{name: "", type: "ALIAS", content: "example.github.io"}]} in @dnsimple.calls
    end
  end

  describe ".add_cname_record" do
    setup [:setup_empty_connection]

    test "adds the cname record", %{connection: connection, account: account} do
      {:ok, _, _} = @connections._add_cname_record(connection, account)

      assert {:create_record, [account, "example.com", %{name: "www", type: "CNAME", content: "example.com"}]} in @dnsimple.calls
    end

    test "stores the record id in the connection", %{connection: connection, account: account} do
      {:ok, [connection, _], _} = @connections._add_cname_record(connection, account)

      stored_connection = @connection_repo.get(connection.id)
      refute connection.dnsimple_cname_id == nil
      refute stored_connection.dnsimple_cname_id == nil
      assert connection.dnsimple_cname_id == stored_connection.dnsimple_cname_id
    end

    test "returns the correct rollback function", %{connection: connection, account: account} do
      {:ok, [connection, _], rollback} = @connections._add_cname_record(connection, account)

      TransactionalPipeline.revert(rollback)

      stored_connection = @connection_repo.get(connection.id)
      assert stored_connection.dnsimple_cname_id == nil
      assert {:delete_record, [account, "example.com", connection.dnsimple_cname_id]} in @dnsimple.calls
    end
  end


  def reset_dummies(context) do
    @dnsimple.reset
    context
  end

  def setup_account(context) do
    {:ok, account} = @account_repo.put(%GithubPagesConnector.Account{dnsimple_account_id: "dnsimple_account_id"})
    Map.put(context, :account, account)
  end

  def setup_empty_connection(context) do
    {:ok, connection} = @connection_repo.put(%Connection{dnsimple_domain: "example.com", github_repository: "example.github.io"})
    Map.put(context, :connection, connection)
  end

end
