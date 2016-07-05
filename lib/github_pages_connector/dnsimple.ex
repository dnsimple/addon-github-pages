defmodule GithubPagesConnector.Dnsimple do
  alias GithubPagesConnector.Account

  @base_url Application.get_env(:github_pages_connector, :dnsimple_base_url)
  @client_id Application.get_env(:github_pages_connector, :dnsimple_client_id)
  @client_secret Application.get_env(:github_pages_connector, :dnsimple_client_secret)

  def oauth_authorize_url(state: state) do
    Dnsimple.OauthService.authorize_url(client, @client_id, state: state)
  end

  def oauth_authorization(code: code, state: state) do
    case Dnsimple.OauthService.exchange_authorization_for_token(client, %{
      code: code,
      state: state,
      client_id: @client_id,
      client_secret: @client_secret,
    }) do
      {:ok, response} -> {:ok, response.data.account_id, response.data.access_token}
      {:error, error} -> {:error, error}
    end
  end

  def list_all_domains(account = %Account{}) do
    access_token = account.dnsimple_access_token
    account_id   = account.dnsimple_account_id

    case Dnsimple.DomainsService.domains(client(access_token), account_id) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> {:error, error}
    end
  end

  def create_record(account = %Account{}, domain_name, record_data) do
    access_token = account.dnsimple_access_token
    account_id   = account.dnsimple_account_id
    record_data  = Enum.into(%{}, record_data)

    case Dnsimple.ZonesService.create_record(client(access_token), account_id, domain_name, record_data) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> {:error, error}
    end
  end


  defp client(access_token \\ nil) do
    %Dnsimple.Client{base_url: @base_url, access_token: access_token}
  end

end
