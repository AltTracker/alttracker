defmodule Cryptofolio.Web.TradeController do
  use Cryptofolio.Web, :controller

  alias Cryptofolio.Dashboard

  import Canary.Plugs

  plug :load_and_authorize_resource, model: Cryptofolio.Dashboard.Trade, only: [:show, :edit, :update, :delete]
  use Cryptofolio.Web.AuthorizationController

  def index(conn, _params) do
    user = conn.assigns[:current_user]

    show_user(conn, user)
  end

  def username(conn, %{ "username" => username }) do
    user = Dashboard.get_portfolio_by_username(username)

    show_user(conn, user)
  end

  def show_user(conn, user) do
    if user do
      current_user = conn.assigns[:current_user]
      owned = if current_user, do: current_user.id === user.id

      portfolio = Dashboard.get_portfolio(user)
      fiat_exchange = Dashboard.get_fiat_exchange(user)

      render(conn, "index.html", portfolio: portfolio, fiat: fiat_exchange, owned: owned)
    else
      redirect conn, to: "/"
    end
  end

  def new(conn, _params) do
    changeset = Dashboard.change_trade(%Cryptofolio.Dashboard.Trade{})
    btc_price = Dashboard.get_coin_price("BTC")

    case Dashboard.list_currencies() do
      currencies ->
        conn
        |> render("new.html", changeset: changeset, currencies: currencies, btc_price: btc_price)
    end
  end

  def create(conn, %{"trade" => trade_params}) do
    case Dashboard.create_user_trade(conn.assigns[:current_user], trade_params) do
      {:ok, trade} ->
        conn
        |> put_flash(:info, "Trade created successfully.")
        |> redirect(to: trade_path(conn, :index))
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
        |> redirect(to: trade_path(conn, :show, trade))
      {:error, %Ecto.Changeset{} = changeset} ->
        case Dashboard.list_currencies() do
          currencies ->
            conn
            |> render("edit.html", trade: trade, changeset: changeset, currencies: currencies)
        end
    end
  end

  def delete(conn, %{}) do
    trade = conn.assigns[:trade]
    {:ok, _trade} = Dashboard.delete_trade(trade)

    conn
    |> put_flash(:info, "Trade deleted successfully.")
    |> redirect(to: trade_path(conn, :index))
  end
end
