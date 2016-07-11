defmodule GithubPagesConnector.Account do
  defstruct [
    :dnsimple_account_id,
    :dnsimple_access_token,
    :github_account_id,
    :github_account_login,
    :github_access_token,
  ]
end
