use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :github_pages_connector, GithubPagesConnector.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :github_pages_connector, GithubPagesConnector.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "github_pages_connector_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :github_pages_connector,
  dnsimple: GithubPagesConnector.DnsimpleDummy,
  dnsimple_base_url: "https://api.t.dnsimple.com",
  dnsimple_client_id: "client_id",
  dnsimple_client_secret: "client_secret"

config :github_pages_connector,
  github: GithubPagesConnector.GithubDummy,
  github_client_id: "client_id",
  github_client_secret: "client_secret",
  github_redirect_uri: "http://localhost:4000/github/callback"
