defmodule Cryptofolio.Web.PortfolioController do
  use Cryptofolio.Web, :controller

  alias Coherence.Config
  alias Cryptofolio.Dashboard

  import Canary.Plugs

  plug :load_and_authorize_resource, model: Cryptofolio.Dashboard.Portfolio, only: [:edit, :update, :delete], persisted: true
  plug Coherence.Authentication.Session, [protected: true] when action in [:index, :toggle_privacy]
  use Cryptofolio.Web.AuthorizationController

  def index(conn, _params) do
    portfolio = Dashboard.get_or_create_user_portfolio(conn.assigns[:current_user])

    get_portfolio(conn, portfolio)
  end

  def show(conn, %{ "id" => id }) do
    {id, ""} = Integer.parse(id)
    portfolio = Dashboard.get_portfolio(id)

    get_portfolio(conn, portfolio)
  end

  defp get_portfolio(conn, portfolio) do
    if portfolio do
      current_user = conn.assigns[:current_user]
      owned = if current_user, do: current_user.id === portfolio.user_id, else: false
      owner = portfolio.user
      is_private = !portfolio.is_public_all

      fiat_exchange = Dashboard.get_fiat_exchange(current_user)
      portfolio = Dashboard.get_portfolio_for_dashboard(portfolio)
      portfolios = Dashboard.list_portfolios(current_user)

      params = [portfolio: portfolio, portfolios: portfolios, fiat: fiat_exchange, owner: owner, owned: owned, is_private: is_private]
      case {owned, is_private} do
        {true, _} -> render(conn, "index.html", params)
        {false, false} -> render(conn, "index.html", params)
        {false, true} -> render(conn, "404.html")
      end
    else
      render(conn, "404.html")
    end
  end

  def new(conn, _params) do
    case Dashboard.change_user_portfolio() do
      changeset ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def create(conn, %{"portfolio" => portfolio_params}) do
    case Dashboard.create_user_portfolio(conn.assigns[:current_user], portfolio_params) do
      {:ok, portfolio} ->
        conn
        |> put_flash(:info, "Portfolio created successfully.")
        |> redirect(to: portfolio_path(conn, :show, portfolio.id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{}) do
    portfolio = conn.assigns[:portfolio]
    changeset = Dashboard.change_portfolio(portfolio)

    render(conn, "edit.html", portfolio: portfolio, changeset: changeset)
  end

  def update(conn, %{"portfolio" => portfolio_params}) do
    portfolio = conn.assigns[:portfolio]

    case Dashboard.update_portfolio(portfolio, portfolio_params) do
      {:ok, portfolio} ->
        conn
        |> put_flash(:info, "Portfolio updated successfully.")
        |> redirect(to: portfolio_path(conn, :show, portfolio))
      {:error, %Ecto.Changeset{} = changeset} ->
        case Dashboard.list_currencies() do
          currencies ->
            conn
            |> render("edit.html", portfolio: portfolio, changeset: changeset, currencies: currencies)
        end
    end
  end

  def toggle_privacy(conn, %{ "id" => id }) do
    {id, ""} = Integer.parse(id)
    portfolio = Dashboard.get_portfolio(id)

    case Dashboard.toggle_privacy(portfolio) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Portfolio is now " <> Cryptofolio.Web.TradeView.privacy_text(portfolio))
        |> redirect(to: portfolio_path(conn, :show, portfolio.id))
    end
  end

  def delete(conn, %{}) do
    user = conn.assigns[:current_user]
    portfolio = conn.assigns[:portfolio]

    case Dashboard.delete_portfolio(user, portfolio) do
      {:ok, _portfolio} ->
        conn
        |> put_flash(:info, "Portfolio deleted successfully.")
        |> redirect(to: portfolio_path(conn, :index))
      {:error, [reason: reason]} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: portfolio_path(conn, :show, portfolio.id))
    end
  end
end
