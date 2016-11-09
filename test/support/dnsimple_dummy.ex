defmodule GithubPagesConnector.DnsimpleDummyAgent do
  use DummyAgent

  def oauth_authorize_url(state: _state) do
    "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
    {:ok, "dnsimple_account_id", "dnsimple_account_email", "dnsimple_access_token"}
  end

  def list_all_domains(account) do
    record_call(:list_all_domains, [account])
    {:ok, get_stubbed_value(:list_all_domains, [])}
  end

  def create_record(account, domain_name, record_data) do
    record_call(:create_record, [account, domain_name, record_data])
    {:ok, get_stubbed_value(:create_record, %Dnsimple.ZoneRecord{id: 1, type: "ALIAS", content: record_data.content})}
  end

  def delete_record(account, domain_name, record_id) do
    record_call(:delete_record, [account, domain_name, record_id])
    :ok
  end

  def get_applied_services(account, domain_name) do
    record_call(:get_applied_services, [account, domain_name])
    {:ok, get_stubbed_value(:get_applied_services, [])}
  end

  def disable_service(account, domain_name, applied_service_id) do
    record_call(:disable_service, [account, domain_name, applied_service_id])
    :ok
  end

end
