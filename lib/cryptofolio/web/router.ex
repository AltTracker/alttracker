defmodule Cryptofolio.Web.Router do
  use Cryptofolio.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", Cryptofolio.Web do
    pipe_through :browser

    get "/", TradeController, :index
    resources "/trades", TradeController
  end

  scope "/", Cryptofolio.Web do
    pipe_through :protected
  end

  # Other scopes may use custom stacks.
  # scope "/api", Cryptofolio.Web do
  #   pipe_through :api
  # end
end
