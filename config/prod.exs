use Mix.Config

config :logger, level: :info

config :github_pages_connector, GithubPagesConnector.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "github-pages-connector.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :github_pages_connector, GithubPagesConnector.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("DATABASE_POOL_SIZE") || "10"),
  ssl: true

config :github_pages_connector,
  github_client_id: System.get_env("GITHUB_CLIENT_ID"),
  github_client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  github_redirect_uri: System.get_env("GITHUB_REDIRECT_URI"),
  dnsimple_client_id: System.get_env("DNSIMPLE_CLIENT_ID"),
  dnsimple_client_secret: System.get_env("DNSIMPLE_CLIENT_SECRET")
