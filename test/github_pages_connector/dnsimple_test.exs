defmodule GithubPagesConnector.DnsimpleTest do
  use ExUnit.Case, async: true

  alias GithubPagesConnector.Dnsimple

  describe ".oauth_authorize_url" do
    test "generates the OAuth dance url" do
      expected_url = "https://t.dnsimple.com/oauth/authorize?response_type=code&client_id=client_id&state=abcd"
      assert Dnsimple.oauth_authorize_url(state: "abcd") == expected_url
    end
  end

end
