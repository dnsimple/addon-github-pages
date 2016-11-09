defmodule GithubPagesConnector.DnsimpleDummy do
  use DummyAgent

  def oauth_authorize_url(state: _state) do
    "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
    {:ok, "dnsimple_account_id", "dnsimple_account_email", "dnsimple_access_token"}
  end

  def list_all_domains(account) do
    record_call(:list_all_domains, [account])
    get_stubbed_value(:list_all_domains, {:ok, []})
  end

  def create_record(account, domain_name, record_data) do
    record_call(:create_record, [account, domain_name, record_data])
    get_stubbed_value(:create_record, {:ok, %Dnsimple.ZoneRecord{id: 1, type: "ALIAS", content: record_data.content}})
  end

  def delete_record(account, domain_name, record_id) do
    record_call(:delete_record, [account, domain_name, record_id])
    get_stubbed_value(:delete_record, :ok)
  end

  def get_applied_services(account, domain_name) do
    record_call(:get_applied_services, [account, domain_name])
    get_stubbed_value(:get_applied_services, {:ok, []})
  end

  def disable_service(account, domain_name, applied_service_id) do
    record_call(:disable_service, [account, domain_name, applied_service_id])
    get_stubbed_value(:disable_service, :ok)
  end

end
