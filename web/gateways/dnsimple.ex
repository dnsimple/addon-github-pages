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
        {:ok, error_message(error)}
    end
  end

  def list_all_domains(account = %Account{dnsimple_account_id: account_id}) do
    case Dnsimple.Domains.list_domains(client(account), account_id) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> {:error, error_message(error)}
    end
  end

  def create_record(account = %Account{dnsimple_account_id: account_id}, domain_name, record_data) do
    case Dnsimple.Zones.create_zone_record(client(account), account_id, domain_name, record_data) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> {:error, error_message(error)}
    end
  end

  def delete_record(account = %Account{dnsimple_account_id: account_id}, domain_name, record_id) do
    case Dnsimple.Zones.delete_zone_record(client(account), account_id, domain_name, record_id) do
      {:ok, _response} -> :ok
      {:error, error}  -> 
        IO.inspect(error)
        {:error, error_message(error)}
    end
  end

  def get_applied_services(account = %Account{dnsimple_account_id: account_id}, domain_name) do
    case Dnsimple.Services.applied_services(client(account), account_id, domain_name) do
      {:ok, response} -> {:ok, response.data}
      {:error, error} -> {:error, error_message(error)}
    end
  end

  def enable_service(account = %Account{dnsimple_account_id: account_id}, domain_name, service_id, github_name) do
    case Dnsimple.Services.apply_service(client(account), account_id, domain_name, service_id, github_name: github_name) do
      {:ok, _response} -> :ok
      {:error, error}  -> {:error, error_message(error)}
    end
  end

  def disable_service(account = %Account{dnsimple_account_id: account_id}, domain_name, service_id) do
    case Dnsimple.Services.unapply_service(client(account), account_id, domain_name, service_id) do
      {:ok, _response} -> :ok
      {:error, error}  -> {:error, error_message(error)}
    end
  end

  defp get_account_email(access_token) do
    case Dnsimple.Identity.whoami(client(access_token)) do
      {:ok, response} -> response.data.account.email
      {:error, error} -> {:error, error_message(error)}
    end
  end

  defp client, do: client(%Account{})
  defp client(%Account{dnsimple_access_token: access_token}), do: client(access_token)
  defp client(access_token) do
    %Dnsimple.Client{base_url: @base_url, access_token: access_token}
  end

  defp error_message(error) do
    message = error.message
    body    = Poison.decode!(error.http_response.body)
    errors  = body["errors"]["base"]
    if is_list(errors) && !Enum.empty?(errors) do
      message = "#{message}: #{Enum.join(errors, ". ")}"
    else
      message
    end
  end

end
