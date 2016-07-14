defmodule GithubPagesConnector.Router do
  use GithubPagesConnector.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GithubPagesConnector do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/dnsimple/authorize", DnsimpleOauthController, :new
    get "/dnsimple/callback",  DnsimpleOauthController, :create
    get "/github/authorize",   GithubOauthController,   :new
    get "/github/callback",    GithubOauthController,   :create

    resources "/connection", ConnectionController, only: [:index, :new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", GithubPagesConnector do
  #   pipe_through :api
  # end
end
