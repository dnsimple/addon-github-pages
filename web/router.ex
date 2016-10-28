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
    pipe_through :browser

    get "/", PageController, :index
    get "/login", PageController, :login
    get "/logout", PageController, :logout

    get "/dnsimple/authorize", DnsimpleOauthController, :new
    get "/dnsimple/callback",  DnsimpleOauthController, :create
    get "/github/authorize",   GithubOauthController,   :new
    get "/github/callback",    GithubOauthController,   :create

    post "/connection/preview", ConnectionController, :preview
    resources "/connection",    ConnectionController, except: [:edit, :update]

  end

  # Other scopes may use custom stacks.
  # scope "/api", GithubPagesConnector do
  #   pipe_through :api
  # end
end
