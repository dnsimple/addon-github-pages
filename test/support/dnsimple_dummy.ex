defmodule GithubPagesConnector.DnsimpleDummy do
  use DummyAgent

  def oauth_authorize_url(state: _state) do
    "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
    {:ok, "dnsimple_account_id", "dnsimple_account_email", "dnsimple_access_token"}
  end

  def list_all_domains(account) do
    args = [account]
    record_call(:list_all_domains, args)
    get_stubbed_value(:list_all_domains, args, {:ok, []})
  end

  def create_record(account, domain_name, record_data) do
    args = [account, domain_name, record_data]
    record_call(:create_record, args)
    get_stubbed_value(:create_record, args, {:ok, Map.merge(%Dnsimple.ZoneRecord{id: :rand.uniform(100_000)}, record_data)})
  end

  def delete_record(account, domain_name, record_id) do
    args = [account, domain_name, record_id]
    record_call(:delete_record, args)
    get_stubbed_value(:delete_record, args, :ok)
  end

  def get_applied_services(account, domain_name) do
    args = [account, domain_name]
    record_call(:get_applied_services, args)
    get_stubbed_value(:get_applied_services, args, {:ok, []})
  end

  def enable_service(account, domain_name, service_id, github_name) do
    record_call(:enable_service, [account, domain_name, service_id, github_name])
    get_stubbed_value(:enable_service, :ok)
  end

  def disable_service(account, domain_name, applied_service_id) do
    args = [account, domain_name, applied_service_id]
    record_call(:disable_service, args)
    get_stubbed_value(:disable_service, args, :ok)
  end

end
