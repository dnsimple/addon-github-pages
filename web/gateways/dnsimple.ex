defmodule GithubPagesConnector.Gateways.Dnsimple do
  alias GithubPagesConnector.Account

  @base_url Application.fetch_env!(:github_pages_connector, :dnsimple_base_url)
  @client_id Application.fetch_env!(:github_pages_connector, :dnsimple_client_id)
  @client_secret Application.fetch_env!(:github_pages_connector, :dnsimple_client_secret)

  def oauth_authorize_url(state: state) do
    Dnsimple.Oauth.authorize_url(client, @client_id, state: state)
  end

  def oauth_authorization(code: code, state: state) do
    case Dnsimple.Oauth.exchange_authorization_for_token(client, %{
      code: code,
      state: state,
      client_id: @client_id,
      client_secret: @client_secret,
    }) do
      {:ok, response} ->
        access_token  = response.data.access_token
        account_id    = response.data.account_id
        account_email = get_account_email(access_token)
        {:ok, account_id, account_email, access_token}
      {:error, error} ->
        raise RuntimeError, message: error.message
    end
  end

  def list_all_domains(account = %Account{dnsimple_account_id: account_id}) do
    case Dnsimple.Domains.list_domains(client(account), account_id) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> raise RuntimeError, message: error.message
    end
  end

  def create_record(account = %Account{dnsimple_account_id: account_id}, domain_name, record_data) do
    case Dnsimple.Zones.create_zone_record(client(account), account_id, domain_name, record_data) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> raise RuntimeError, message: error.message
    end
  end

  def delete_record(account = %Account{dnsimple_account_id: account_id}, domain_name, record_id) do
    case Dnsimple.Zones.delete_zone_record(client(account), account_id, domain_name, record_id) do
      {:ok, _response} -> :ok
      {:error, error} -> raise RuntimeError, message: error.message
    end
  end


  defp get_account_email(access_token) do
    case Dnsimple.Identity.whoami(client(access_token)) do
      {:ok, response} -> response.data.account.email
      {:error, error} -> raise RuntimeError, message: error.message
    end
  end

  defp client, do: client(%Account{})
  defp client(%Account{dnsimple_access_token: access_token}), do: client(access_token)
  defp client(access_token) do
    %Dnsimple.Client{base_url: @base_url, access_token: access_token}
  end

end
