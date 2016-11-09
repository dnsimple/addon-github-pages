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


  defp get_stubbed_value(function, default) do
    Agent.get(__MODULE__, &Map.get_lazy(&1, function, fn -> default end))
  end

  defp record_call(function, args) do
    Agent.update(__MODULE__, &Map.update(&1, :calls, [], fn(calls) -> calls ++ [{function, args}] end))
  end

end
