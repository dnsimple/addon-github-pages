defmodule GithubPagesConnector.ConnectionsTest do
  use GithubPagesConnector.ConnCase

  alias GithubPagesConnector.Connection
  alias GithubPagesConnector.TransactionalPipeline

  @account_repo GithubPagesConnector.AccountEctoRepo
  @connection_repo GithubPagesConnector.ConnectionEctoRepo
  @connections GithubPagesConnector.Services.Connections
  @dnsimple GithubPagesConnector.DnsimpleDummy
  @github GithubPagesConnector.GithubDummy


  setup [:reset_dummies, :setup_account]


  describe "._save_connection" do
    setup context do
      connection = %Connection{dnsimple_domain: "example.com", github_repository: "example.github.io"}
      Map.put(context, :connection, connection)
    end

    test "it saves the connection in persistent storage", %{connection: connection, account: account} do
      {:ok, [saved_connection, _], _} = @connections._save_connection(connection, account)

      refute @connection_repo.get(saved_connection.id) == nil
    end

    test "returns the correct rollback function", %{connection: connection, account: account} do
      {:ok, [saved_connection, _], rollback} = @connections._save_connection(connection, account)

      TransactionalPipeline.revert(rollback)

      assert @connection_repo.get(saved_connection.id) == nil
    end
  end

  describe "._delete_connection" do
    setup [:setup_empty_connection]

    test "it deletes the connection from persitent storage", %{connection: connection, account: account} do
      {:ok, _, _} = @connections._delete_connection(connection, account)

      assert @connection_repo.get(connection.id) == nil
    end

    test "returns no rollback function because it's the last function", %{connection: connection, account: account} do
      {:ok, _, rollback} = @connections._delete_connection(connection, account)

     assert rollback == []
    end
  end

  describe "._add_alias_record" do
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

  describe "._remove_alias_record" do
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

  describe "._add_cname_record" do
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

  describe "._remove_cname_record" do
    setup context do
      {:ok, connection} = @connection_repo.put(%Connection{dnsimple_domain: "example.com", github_repository: "example.github.io", dnsimple_cname_id: 67890})
      Map.put(context, :connection, connection)
    end

    test "removes the cname record", %{connection: connection, account: account} do
      {:ok, _, _} = @connections._remove_cname_record(connection, account)

      assert {:delete_record, [account, "example.com", connection.dnsimple_cname_id]} in @dnsimple.calls
    end

    test "clears the record id in the connection", %{connection: connection, account: account} do
      {:ok, [connection, _], _} = @connections._remove_cname_record(connection, account)

      stored_connection = @connection_repo.get(connection.id)
      assert connection.dnsimple_cname_id == nil
      assert stored_connection.dnsimple_cname_id == nil
    end

    test "returns the correct rollback function", %{connection: connection, account: account} do
      {:ok, _, rollback} = @connections._remove_cname_record(connection, account)

      TransactionalPipeline.revert(rollback)

      stored_connection = @connection_repo.get(connection.id)
      refute stored_connection.dnsimple_cname_id == nil
      refute stored_connection.dnsimple_cname_id == connection.dnsimple_cname_id
      assert {:create_record, [account, "example.com", %{name: "www", type: "CNAME", content: "example.com"}]} in @dnsimple.calls
    end
  end

  describe "_create_cname_file" do
    setup [:setup_empty_connection]

    test "creates the cname file", %{connection: connection, account: account} do
      {:ok, _, _} = @connections._create_cname_file(connection, account)

      assert {:create_file, [account, "example.github.io", "CNAME", "example.com", "Configure custom domain with DNSimple"]} in @github.calls
    end

    test "stores the created file SHA in the connection", %{connection: connection, account: account} do
      {:ok, [connection, _], _} = @connections._create_cname_file(connection, account)

      stored_connection = @connection_repo.get(connection.id)
      refute connection.github_file_sha == nil
      refute stored_connection.github_file_sha == nil
      assert stored_connection.github_file_sha == connection.github_file_sha
    end

    test "returns the correct rollback function", %{connection: connection, account: account} do
      {:ok, [connection, _], rollback} = @connections._create_cname_file(connection, account)

      TransactionalPipeline.revert(rollback)

      stored_connection = @connection_repo.get(connection.id)
      assert stored_connection.github_file_sha == nil
      assert {:delete_file, [account, "example.github.io", "CNAME", connection.github_file_sha, "Remove DNSimple custom domain configuration"]} in @github.calls
    end
  end

  describe "_remove_cname_file" do
    setup context do
      {:ok, connection} = @connection_repo.put(%Connection{dnsimple_domain: "example.com", github_repository: "example.github.io", github_file_sha: "cname_file_sha"})
      Map.put(context, :connection, connection)
    end

    test "deletes the cname file", %{connection: connection, account: account} do
      {:ok, _, _} = @connections._remove_cname_file(connection, account)

      assert {:delete_file, [account, "example.github.io", "CNAME", connection.github_file_sha, "Remove DNSimple custom domain configuration"]} in @github.calls
    end

    test "clears the file SHA in the connection", %{connection: connection, account: account} do
      {:ok, [connection, _], _} = @connections._remove_cname_file(connection, account)

      stored_connection = @connection_repo.get(connection.id)
      assert connection.github_file_sha == nil
      assert stored_connection.github_file_sha == nil
    end

    test "returns the correct rollback function", %{connection: connection, account: account} do
      {:ok, _, rollback} = @connections._remove_cname_file(connection, account)

      TransactionalPipeline.revert(rollback)

      stored_connection = @connection_repo.get(connection.id)
      refute stored_connection.github_file_sha == nil
      assert {:create_file, [account, "example.github.io", "CNAME", "example.com", "Configure custom domain with DNSimple"]} in @github.calls
    end
  end

  describe "_update_cname_file" do
    setup context do
      {:ok, connection} = @connection_repo.put(%Connection{dnsimple_domain: "example.com", github_repository: "example.github.io", github_file_sha: "cname_file_sha"})
      Map.merge(context, %{connection: connection, sha: "current-sha", content: "current-content"})
    end

    test "updates the cname file", %{connection: connection, account: account, content: content, sha: sha} do
      {:ok, _, _} = @connections._update_cname_file(connection, account, connection.dnsimple_domain, content, sha)

      assert {:update_file, [account, "example.github.io", "CNAME", "example.com", sha, "Configure custom domain with DNSimple"]} in @github.calls
    end

    test "stores the file SHA in the connection", %{connection: connection, account: account, content: content, sha: sha} do
      {:ok, [connection, _], _} = @connections._update_cname_file(connection, account, connection.dnsimple_domain, content, sha)

      stored_connection = @connection_repo.get(connection.id)
      refute connection.github_file_sha == nil
      assert stored_connection.github_file_sha == connection.github_file_sha
    end

    test "returns the correct rollback function", %{connection: connection, account: account, content: content, sha: sha} do
      {:ok, [connection, _], rollback} = @connections._update_cname_file(connection, account, connection.dnsimple_domain, content, sha)

      TransactionalPipeline.revert(rollback)

      stored_connection = @connection_repo.get(connection.id)
      assert stored_connection.github_file_sha == "sha"
      assert {:update_file, [account, "example.github.io", "CNAME", content, "sha", "Configure custom domain with DNSimple"]} in @github.calls
    end
  end


  defp reset_dummies(context) do
    @dnsimple.reset
    @github.reset
    context
  end

  defp setup_account(context) do
    {:ok, account} = @account_repo.put(%GithubPagesConnector.Account{dnsimple_account_id: "dnsimple_account_id"})
    Map.put(context, :account, account)
  end

  defp setup_empty_connection(context) do
    {:ok, connection} = @connection_repo.put(%Connection{account_id: context[:account].id, dnsimple_domain: "example.com", github_repository: "example.github.io"})
    Map.put(context, :connection, connection)
  end

end
