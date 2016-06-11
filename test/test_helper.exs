ExUnit.start

Mix.Task.run "ecto.create", ~w(-r GithubPagesConnector.Repo --quiet)
# Mix.Task.run "ecto.migrate", ~w(-r GithubPagesConnector.Repo --quiet)
Ecto.Adapters.SQL.Sandbox.mode(GithubPagesConnector.Repo, :manual)
