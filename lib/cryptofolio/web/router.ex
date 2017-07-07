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

    get "/", PageController, :index
    get "/about", PageController, :about
    scope "/portfolio" do
      get "/", PortfolioController, :index
      get "/:portfolio_id", PortfolioController, :show
      scope "/:portfolio_id" do
        resources "/trades", TradeController, except: [:index]
      end
      delete "/toggle_privacy", TradeController, :toggle_privacy
    end
  end

  scope "/", Cryptofolio.Web do
    pipe_through :protected

    get "/profile", UserController, :edit
    post "/profile", UserController, :update
    patch "/profile", UserController, :update
    put   "/profile", UserController, :update
  end

  scope "/api", Cryptofolio.Web do
    pipe_through :api

    get "/coin_daily_history/:symbol", MarketcapController, :coin_daily_history
  end
end
