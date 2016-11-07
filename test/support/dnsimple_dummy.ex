defmodule GithubPagesConnector.DnsimpleDummy do

  def oauth_authorize_url(state: _state) do
    "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
    {:ok, "dnsimple_account_id", "dnsimple_account_email", "dnsimple_access_token"}
  end

  def list_all_domains(_account) do
    {:ok, [%Dnsimple.Domain{name: "domain1.com"}, %Dnsimple.Domain{name: "domain2.com"}]}
  end

  def create_record(_account, _domain_name, record_data) do
    {:ok, %Dnsimple.ZoneRecord{id: 1, type: "ALIAS", content: record_data.content}}
  end

  def delete_record(_account, _domain_name, _record_id) do
    :ok
  end

  def get_applied_services(_account, _domain_name) do
    {:ok, []}
  end

  def disable_service(_account, _domain_name, _applied_service_id) do
    :ok
  end

end
