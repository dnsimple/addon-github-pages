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

config :github_pages_connector, github: GithubPagesConnector.Gateways.Github
config :github_pages_connector, github_token_uri: "https://github.com/login/oauth/access_token"
config :github_pages_connector, github_authorize_uri: "https://github.com/login/oauth/authorize"

config :github_pages_connector, dnsimple: GithubPagesConnector.Gateways.Dnsimple
config :github_pages_connector, dnsimple_base_url: "https://api.dnsimple.com"


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

