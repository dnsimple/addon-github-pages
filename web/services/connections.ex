defmodule GithubPagesConnector.Services.Connections do
  alias GithubPagesConnector.Account
  alias GithubPagesConnector.Connection
  alias GithubPagesConnector.TransactionalPipeline

  @repo GithubPagesConnector.ConnectionEctoRepo
  @github Application.get_env(:github_pages_connector, :github)
  @dnsimple Application.get_env(:github_pages_connector, :dnsimple)


  def list_pages_repositories(account = %Account{}) do
    {:ok, repositories} = @github.list_all_repositories(account)
    Enum.filter(repositories, fn(repo) -> String.ends_with?(repo["name"], "github.io") end)
  end

  def list_domains(account = %Account{}) do
    {:ok, domains} = @dnsimple.list_all_domains(account)
    domains
  end

  def list_connections(account = %Account{}), do: list_connections(account.id)
  def list_connections(account_id), do: @repo.list_connections(account_id)

  def connect(account, connection_data) do
    connection = struct(Connection, Keyword.merge(connection_data, account_id: account.id))
    pipeline   = [
      &_save_connection/2,
      &_add_alias_record/2,
      &_add_cname_record/2,
      &_configure_cname_file/2,
    ]

    case TransactionalPipeline.run(pipeline, [connection, account]) do
      {:ok, [connection, _]} -> {:ok, connection}
      {:error, error}        -> {:error, error}
    end
  end

  def disconnect(account, connection_id) do
    connection = @repo.get(connection_id)
    pipeline   = [
      &_remove_alias_record/2,
      &_remove_cname_record/2,
      &_remove_cname_file/2,
      &_delete_connection/2,
    ]

    case TransactionalPipeline.run(pipeline, [connection, account]) do
      {:ok, [connection, _]} -> {:ok, connection}
      {:error, error}        -> {:error, error}
    end
  end


  # Connection management
  ##############################################################################

  def _save_connection(connection, account) do
    case @repo.put(connection) do
      {:ok, saved_connection} ->
        {:ok, [saved_connection, account], [fn -> _delete_connection(saved_connection, account) end]}
      {:error, details} ->
        {:error, details}
    end
  end

  def _delete_connection(connection, account) do
    case @repo.remove(connection) do
      {:ok, deleted_connection} ->
        {:ok, [deleted_connection, account], []}
      {:error, details} ->
        {:error, details}
    end
  end

  # Record management
  ##############################################################################

  def _add_alias_record(connection, account) do
    record_data = %{name: "", type: "ALIAS", content: connection.github_repository}
    case @dnsimple.create_record(account, connection.dnsimple_domain, record_data) do
      {:ok, record} ->
        {:ok, connection} = @repo.put_attribute(connection, :dnsimple_alias_id, record.id)
        {:ok, [connection, account], [fn -> _remove_alias_record(connection, account) end]}
      {:error, details} ->
        {:error, details}
    end
  end

  def _remove_alias_record(connection, account) do
    case @dnsimple.delete_record(account, connection.dnsimple_domain, connection.dnsimple_alias_id) do
      :ok ->
        {:ok, connection} = @repo.put_attribute(connection, :dnsimple_alias_id, nil)
        {:ok, [connection, account], [fn -> _add_alias_record(connection, account) end]}
      {:error, details} ->
        {:error, details}
    end
  end

  def _add_cname_record(connection, account) do
    record_data = %{name: "www", type: "CNAME", content: connection.dnsimple_domain}
    case @dnsimple.create_record(account, connection.dnsimple_domain, record_data) do
      {:ok, record} ->
        {:ok, connection} = @repo.put_attribute(connection, :dnsimple_cname_id, record.id)
        {:ok, [connection, account], [fn -> _remove_cname_record(connection, account) end]}
      {:error, details} ->
        {:error, details}
    end
  end

  def _remove_cname_record(connection, account) do
    case @dnsimple.delete_record(account, connection.dnsimple_domain, connection.dnsimple_cname_id) do
      :ok ->
        {:ok, connection} = @repo.put_attribute(connection, :dnsimple_cname_id, nil)
        {:ok, [connection, account], [fn -> _add_cname_record(connection, account) end]}
      {:error, details} ->
        IO.inspect(details)
        {:error, details}
    end
  end


  # CNAME file management
  ##############################################################################

  @cname_file_path "CNAME"

  def get_cname_file(repository, account) do
    @github.get_file(account, repository, @cname_file_path)
  end

  def _configure_cname_file(connection, account) do
    case get_cname_file(connection.github_repository, account) do
      {:ok, %{content: content, sha: sha}} ->
        _update_cname_file(connection, account, connection.dnsimple_domain, content, sha)
      {:error, :notfound} ->
        _create_cname_file(connection, account)
      {:error, error} ->
        {:error, error}
    end
  end

  def _create_cname_file(connection, account) do
    case @github.create_file(account, connection.github_repository, @cname_file_path, connection.dnsimple_domain, "Configure custom domain with DNSimple") do
      {:ok, commit} ->
        {:ok, connection} = @repo.put_attribute(connection, :github_file_sha, commit["content"]["sha"])
        {:ok, [connection, account], [fn -> _remove_cname_file(connection, account) end]}
      {:error, error} ->
        {:error, error}
    end
  end

  def _remove_cname_file(connection, account) do
    case @github.delete_file(account, connection.github_repository, @cname_file_path, connection.github_file_sha, "Remove DNSimple custom domain configuration") do
      {:ok, _commit} ->
        {:ok, connection} = @repo.put_attribute(connection, :github_file_sha, nil)
        {:ok, [connection, account], [fn -> _create_cname_file(connection, account) end]}
      {:error, error} ->
        {:error, error}
    end
  end

  def _update_cname_file(connection, account, new_content, previous_content, previous_sha) do
    case @github.update_file(account, connection.github_repository, @cname_file_path, new_content, previous_sha, "Configure custom domain with DNSimple") do
      {:ok, commit} ->
        {:ok, connection} = @repo.put_attribute(connection, :github_file_sha, commit["content"]["sha"])
        {:ok, [connection, account], [fn -> _update_cname_file(connection, account, previous_content, new_content, commit["content"]["sha"]) end]}
      {:error, error} ->
        {:error, error}
    end
  end


  # 1-click-service management
  #############################################################################

  # Commented out until this is implemented: https://github.com/aetrion/dnsimple/issues/4248
  # as otherwise you cannot re-apply the service.
  #
  #defp enable_one_click_service(connection, account, service_id) do
  #  @dnsimple.enable_service(account, connection.dnsimple_domain, service_id)
  #end

  #defp disable_one_click_service(connection, account) do
  #  if github_pages_service = get_github_pages_applied_service(connection, account) do
  #    case @dnsimple.disable_service(account, connection.dnsimple_domain, github_pages_service.id) do
  #      :ok ->
  #        revert = fn -> new_enable_one_click_service(connection, account, github_pages_service.id) end
  #        {:ok, [connection, account], [revert]}
  #      {:error, error} ->
  #        {:error, error}
  #    end
  #  else
  #    {:ok, [connection, account], []}
  #  end
  #end

  #defp get_github_pages_applied_service(connection, account) do
  #  {:ok, applied_services} = @dnsimple.get_applied_services(account, connection.dnsimple_domain)
  #  Enum.find(applied_services, &(&1.name == "GitHub Pages"))
  #end

end
