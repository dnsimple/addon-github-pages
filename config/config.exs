# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :github_pages_connector, GithubPagesConnector.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "UFUxa78Eu56w02aP5TINyfxJdQAXe86q0yg9ZYGn/Llo1SrgAxzKtIhTkQsZCYOW",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: GithubPagesConnector.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :github_pages_connector, ecto_repos: [GithubPagesConnector.Repo]


config :github_pages_connector, github_client_id: "26bdee190f3d6af8f9e3"
config :github_pages_connector, github_client_secret: "a5f8fb3be0467f30a34f0f574c2c7cd9877463a5"
config :github_pages_connector, github_token_uri: "https://github.com/login/oauth/access_token"
config :github_pages_connector, github_redirect_uri: "http://localhost:4000/github/callback"
config :github_pages_connector, github_authorize_uri: "https://github.com/login/oauth/authorize"

config :github_pages_connector, dnsimple: GithubPagesConnector.Dnsimple
config :github_pages_connector, dnsimple_base_url: "https://api.sandbox.dnsimple.com"
config :github_pages_connector, dnsimple_client_id: "14633962cac66aed"
config :github_pages_connector, dnsimple_client_secret: "vMFp5bDYJ1ngEzLg6rHD9pwrTmo7sCDD"


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

