defmodule Cryptofolio.Dashboard do
  @moduledoc """
  The boundary for the Dashboard system.
  """

  import Ecto.Query, warn: false
  alias Cryptofolio.Repo

  alias Cryptofolio.Trade, as: TradeService
  alias Cryptofolio.User
  alias Cryptofolio.Marketcap
  alias Cryptofolio.Dashboard.Portfolio
  alias Cryptofolio.Dashboard.Trade
  alias Cryptofolio.Dashboard.Currency

  def get_user(id) do
    Repo.get_by! User, id: id
  end

  def get_portfolio(id) do
    Repo.get_by! Portfolio, id: id
  end

  @doc """
  Returns user portfolio
  """
  def get_user_portfolio(%User{} = user) do
    portfolio = user
    |> Ecto.assoc(:portfolio)
    |> first(:inserted_at)
    |> Repo.one

    %Portfolio{ portfolio | user: user }
  end

  def get_portfolio_for_dashboard(portfolio) do
    trades = list_dashboard_trades_for_portfolio(portfolio)
    total = trades
            |> Enum.map(&(Map.get(&1, :current_value)))
            |> Enum.reduce(Decimal.new(0), &Decimal.add/2)
    cost = trades
            |> Enum.map(&(Map.get(&1, :total_cost)))
            |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

    %{
      id: portfolio.id,
      trades: trades,
      total: total,
      cost: cost,
      profit_loss: %{
        value: TradeService.profit_loss(total, cost),
        perc: TradeService.profit_loss_perc(total, cost)
      },
      currencies: Enum.map(trades, &(&1.currency))
    }
  end

  defp list_dashboard_trades_for_portfolio(portfolio) do
    Trade
    |> where(portfolio_id: ^portfolio.id)
    |> join(:inner, [t], _ in assoc(t, :currency)) 
    |> select([trade, curr], {trade, curr})
    |> Repo.all
    |> Enum.map(&add_current_value_assocs/1)
  end

  defp add_current_value_assocs({trade, curr}) do
    currency = trade
               |> Ecto.build_assoc(:currency, curr)
               |> Map.put(:cost_usd, Marketcap.get_coin_price(curr.symbol))
               |> Map.drop([:last_tick])

    trade = trade |> Map.put(:currency, currency)

    trade
    |> Map.put(:total_cost, Cryptofolio.Trade.total_cost(trade))
    |> Map.put(:current_value, Cryptofolio.Trade.current_value(trade))
  end

  defp build_trade_assocs({trade, curr, tick}) do
    currency = Ecto.build_assoc(trade, :currency, curr)

    %Trade{ trade | currency: %Currency{ currency | last_tick: tick } }
  end

  def get_coin_price(symbol) do
    Marketcap.get_coin_price(symbol)
  end

  def get_fiat_exchange(user) do
    symbol = case Repo.one Ecto.assoc(user, :fiat) do
      nil -> "USD"
      fiat -> fiat.symbol
    end

    conversion = case Marketcap.get_fiat_price(symbol) do
      {:ok, v} -> v
      _ -> 1
    end

    %{ symbol: symbol, conversion: conversion }
  end

  @doc """
  Returns the list of trades.

  ## Examples

      iex> list_trades()
      [%Trade{}, ...]

  """
  def list_trades do
    Repo.all(Trade)
  end

  @doc """
  Gets a single trade.

  Raises `Ecto.NoResultsError` if the Trade does not exist.

  ## Examples

      iex> get_trade!(123)
      %Trade{}

      iex> get_trade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trade_with_currency!(id) do
    Trade
    |> join(:inner, [t], _ in assoc(t, :currency)) 
    |> select([trade, curr], {trade, curr})
    |> Repo.get!(id)
    |> Cryptofolio.Dashboard.add_current_value_assocs
  end

  @doc """
  Creates a trade.

  ## Examples

      iex> create_trade(%{field: value})
      {:ok, %Trade{}}

      iex> create_trade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_portfolio_trade(id, attrs \\ %{}) do
    Trade.changeset(%Trade{ portfolio_id: id }, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trade.

  ## Examples

      iex> update_trade(trade, %{field: new_value})
      {:ok, %Trade{}}

      iex> update_trade(trade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trade(%Trade{} = trade, attrs) do
    trade
    |> Trade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Trade.

  ## Examples

      iex> delete_trade(trade)
      {:ok, %Trade{}}

      iex> delete_trade(trade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trade(%Trade{} = trade) do
    Repo.delete(trade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trade changes.

  ## Examples

      iex> change_trade(trade)
      %Ecto.Changeset{source: %Trade{}}

  """
  def change_trade(%Trade{} = trade) do
    Trade.changeset(trade, %{})
  end

  def change_trade(%Trade{} = trade, attrs) do
    Trade.changeset(trade, attrs)
  end

  def list_currencies do
    Currency
    |> order_by(:name)
    |> Repo.all
  end

  def toggle_privacy(user) do
    user
    |> User.changeset(:toggle_privacy)
    |> Repo.update()
  end
end
