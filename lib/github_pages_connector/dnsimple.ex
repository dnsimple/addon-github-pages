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

  def list_all_domains(account = %Account{dnsimple_account_id: account_id}) do
    case Dnsimple.DomainsService.domains(client(account), account_id) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> {:error, error}
    end
  end

  def create_record(account = %Account{dnsimple_account_id: account_id}, domain_name, record_data) do
    case Dnsimple.ZonesService.create_record(client(account), account_id, domain_name, record_data) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> {:error, error}
    end
  end


  defp client, do: client(%Account{})
  defp client(%Account{dnsimple_access_token: access_token}) do
    %Dnsimple.Client{base_url: @base_url, access_token: access_token}
  end

end
