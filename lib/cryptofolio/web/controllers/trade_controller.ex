defmodule Cryptofolio.Web.TradeController do
  use Cryptofolio.Web, :controller

  alias Cryptofolio.Trade
  alias Cryptofolio.Dashboard

  import Canary.Plugs

  plug :load_and_authorize_resource, model: Cryptofolio.Dashboard.Trade, only: [:show, :edit, :update, :delete]
  use Cryptofolio.Web.AuthorizationController

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      portfolio = Dashboard.get_portfolio(conn.assigns[:current_user])

      render(conn, "index.html", portfolio: portfolio)
    else
      redirect conn, to: "/"
    end
  end

  def new(conn, _params) do
    changeset = Dashboard.change_trade(%Cryptofolio.Dashboard.Trade{})
    case Dashboard.list_currencies() do
      {:ok, currencies} ->
        conn
        |> render("new.html", changeset: changeset, currencies: currencies)
    end
  end

  def create(conn, %{"trade" => trade_params}) do
    case Dashboard.create_user_trade(conn.assigns[:current_user], trade_params) do
      {:ok, trade} ->
        conn
        |> put_flash(:info, "Trade created successfully.")
        |> redirect(to: trade_path(conn, :show, trade))
      {:error, %Ecto.Changeset{} = changeset} ->
        {:ok, currencies} = Dashboard.list_currencies()
        render(conn, "new.html", changeset: changeset, currencies: currencies)
    end
  end

  def show(conn, %{"id" => id}) do
    trade = Dashboard.get_trade!(id)
    render(conn, "show.html", trade: trade)
  end

  def edit(conn, %{}) do
    trade = conn.assigns[:trade]
    changeset = Dashboard.change_trade(trade)
    case Dashboard.list_currencies() do
      {:ok, currencies} ->
        conn
        |> render("edit.html", trade: trade, changeset: changeset, currencies: currencies)
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
        render(conn, "edit.html", trade: trade, changeset: changeset)
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
