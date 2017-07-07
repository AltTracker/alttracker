defmodule Cryptofolio.Web.TradeController do
  use Cryptofolio.Web, :controller

  alias Coherence.Config
  alias Cryptofolio.Dashboard

  import Canary.Plugs

  plug :load_and_authorize_resource, model: Cryptofolio.Dashboard.Trade, only: [:new, :create, :show, :edit, :update, :delete]
  plug Coherence.Authentication.Session, [protected: true] when action in [:toggle_privacy]
  use Cryptofolio.Web.AuthorizationController

  def new(conn, %{"portfolio_id" => id}) do
    portfolio = Dashboard.get_portfolio(id)
    btc_price = Dashboard.get_coin_price("BTC")
    total_cost_btc = Decimal.div(Decimal.new(1), btc_price)
    changeset = Dashboard.change_trade(%Cryptofolio.Dashboard.Trade{ amount: 1 }, %{ cost: 1, total_cost: 1, total_cost_btc: total_cost_btc })

    case Dashboard.list_currencies() do
      currencies ->
        conn
        |> render("new.html", changeset: changeset, currencies: currencies, btc_price: btc_price, portfolio: portfolio)
    end
  end

  def create(conn, %{"portfolio_id" => id, "trade" => trade_params}) do
    {id, _} = Integer.parse(id)
    portfolio = Dashboard.get_portfolio(id)
    case Dashboard.create_portfolio_trade(portfolio, trade_params) do
      {:ok, _trade} ->
        conn
        |> put_flash(:info, "Trade created successfully.")
        |> redirect(to: portfolio_path(conn, :show, id))
      {:error, %Ecto.Changeset{} = changeset} ->
        currencies = Dashboard.list_currencies()
        btc_price = Dashboard.get_coin_price("BTC")

        render(conn, "new.html", changeset: changeset, currencies: currencies, btc_price: btc_price)
    end
  end

  def show(conn, %{"id" => id}) do
    trade = Dashboard.get_trade_with_currency!(id)
    fiat_exchange = Dashboard.get_fiat_exchange(conn.assigns[:current_user])

    render(conn, "show.html", trade: trade, fiat: fiat_exchange)
  end

  def edit(conn, %{}) do
    trade = conn.assigns[:trade]
    btc_price = Dashboard.get_coin_price("BTC")
    changeset = Dashboard.change_trade(trade)
    case Dashboard.list_currencies() do
      currencies ->
        conn
        |> render("edit.html", trade: trade, changeset: changeset, currencies: currencies, btc_price: btc_price)
    end
  end

  def update(conn, %{"trade" => trade_params}) do
    trade = conn.assigns[:trade]

    case Dashboard.update_trade(trade, trade_params) do
      {:ok, trade} ->
        conn
        |> put_flash(:info, "Trade updated successfully.")
        |> redirect(to: portfolio_trade_path(conn, :show, trade.portfolio, trade))
      {:error, %Ecto.Changeset{} = changeset} ->
        case Dashboard.list_currencies() do
          currencies ->
            conn
            |> render("edit.html", trade: trade, changeset: changeset, currencies: currencies)
        end
    end
  end

  def toggle_privacy(conn, _params) do
    user = conn.assigns[:current_user]

    case Dashboard.toggle_privacy(user) do
      {:ok, user} ->
        apply(Config.auth_module, Config.update_login, [conn, user, [id_key: Config.schema_key]])

        conn
        |> put_flash(:info, "Portfolio is now " <> Cryptofolio.Web.TradeView.privacy_text(user.private_portfolio))
        |> redirect(to: portfolio_path(conn, :index))
    end
  end

  def delete(conn, %{}) do
    trade = conn.assigns[:trade]
    {:ok, _trade} = Dashboard.delete_trade(trade)

    conn
    |> put_flash(:info, "Trade deleted successfully.")
    |> redirect(to: portfolio_path(conn, :index))
  end
end
