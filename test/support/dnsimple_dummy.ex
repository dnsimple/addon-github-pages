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

defmodule GithubPagesConnector.DnsimpleDummyAgent do
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def stub(function, return_value) do
    Agent.update(__MODULE__, &Map.put(&1, function, return_value))
  end

  def calls do
    Agent.get(__MODULE__, &Map.get_lazy(&1, :calls, fn -> [] end))
  end

  def reset do
    Agent.update(__MODULE__, fn(_) -> Map.new end)
  end

  def list_all_domains(_account) do
    {:ok, [%Dnsimple.Domain{name: "domain1.com"}, %Dnsimple.Domain{name: "domain2.com"}]}
  end


  def oauth_authorize_url(state: _state) do
    "https://test.dnsimple.com/auth/authorize?client_id=client_id&state=state"
  end

  def oauth_authorization(code: _code, state: _state) do
    {:ok, "dnsimple_account_id", "dnsimple_account_email", "dnsimple_access_token"}
  end

  def create_record(_account, _domain_name, record_data) do
    {:ok, %Dnsimple.ZoneRecord{id: 1, type: "ALIAS", content: record_data.content}}
  end

  def delete_record(_account, _domain_name, _record_id) do
    :ok
  end

  def get_applied_services(account, domain_name) do
    record_call(:get_applied_services, [account, domain_name])
    {:ok, get_stubbed_value(:get_applied_services)}
  end

  def disable_service(account, domain_name, applied_service_id) do
    record_call(:disable_service, [account, domain_name, applied_service_id])
    :ok
  end


  defp get_stubbed_value(function) do
    Agent.get(__MODULE__, &Map.get_lazy(&1, function, fn -> [] end))
  end

  defp record_call(function, args) do
    Agent.update(__MODULE__, &Map.update(&1, :calls, [], fn(calls) -> calls ++ [{function, args}] end))
  end

end
