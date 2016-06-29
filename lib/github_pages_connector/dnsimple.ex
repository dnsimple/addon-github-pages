defmodule GithubPagesConnector.Dnsimple do

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

  defp client, do: %Dnsimple.Client{base_url: @base_url}
end
