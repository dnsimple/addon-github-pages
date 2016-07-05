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

config :github_pages_connector, dnsimple: GithubPagesConnector.DnsimpleDummy
config :github_pages_connector, dnsimple_base_url: "https://api.t.dnsimple.com"
config :github_pages_connector, dnsimple_client_id: "client_id"
config :github_pages_connector, dnsimple_client_secret: "client_secret"
