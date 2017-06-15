defmodule Cryptofolio.Dashboard do
  @moduledoc """
  The boundary for the Dashboard system.
  """

  import Ecto.Query, warn: false
  alias Cryptofolio.Repo

  alias Cryptofolio.Dashboard.Trade
  alias Cryptofolio.Dashboard.Currency
  alias Cryptofolio.Dashboard.CurrencyTick

  def list_trades_with_currency_and_last_tick do
    # TODO: optimize and query for last tick only

    Trade
    |> join(:inner, [t], _ in assoc(t, :currency))
    |> join(:left, [_, c], _ in assoc(c, :last_tick))
    |> preload([_, c, t], [currency: {c, last_tick: t}])
    |> Repo.all
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
  def get_trade!(id), do: Repo.get!(Trade, id)

  @doc """
  Creates a trade.

  ## Examples

      iex> create_trade(%{field: value})
      {:ok, %Trade{}}

      iex> create_trade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trade(attrs \\ %{}) do
    %Trade{}
    |> Trade.changeset(attrs)
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

  def list_currencies do
    Repo.all(Currency)
  end
end
