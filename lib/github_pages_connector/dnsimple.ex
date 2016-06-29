defmodule GitHubPagesConnector.Dnsimple do

  @base_url "https://api.sandbox.dnsimple.com"
  @client_id "14633962cac66aed"
  @client_secret "vMFp5bDYJ1ngEzLg6rHD9pwrTmo7sCDD"

  def oauth_authorize_url(state: state) do
    Dnsimple.OauthService.authorize_url(client, @client_id, state: state)
  end

  defp client, do: %Dnsimple.Client{base_url: @base_url}
end
