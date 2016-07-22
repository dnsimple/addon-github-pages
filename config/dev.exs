use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :github_pages_connector, GithubPagesConnector.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
             cd: Path.expand("../", __DIR__)]]

# Watch static and templates for browser reloading.
config :github_pages_connector, GithubPagesConnector.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :github_pages_connector, GithubPagesConnector.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "github_pages_connector_dev",
  hostname: "localhost",
  pool_size: 10

config :github_pages_connector,
  github_client_id: "5b340a410acd78698c9f",
  github_client_secret: "6dce2e55d023949d66521d31896fda97d630cc9a",
  github_redirect_uri: "http://localhost:4000/github/callback",
  dnsimple_base_url: "https://api.sandbox.dnsimple.com",
  dnsimple_client_id: "14633962cac66aed",
  dnsimple_client_secret: "vMFp5bDYJ1ngEzLg6rHD9pwrTmo7sCDD"
