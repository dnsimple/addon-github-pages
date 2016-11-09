ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(GithubPagesConnector.Repo, :manual)
GithubPagesConnector.GithubDummyAgent.start_link
GithubPagesConnector.DnsimpleDummyAgent.start_link

