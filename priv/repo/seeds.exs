# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

defmodule Cryptofolio.Seeder.CoinList do
  def extract_coins_from_coinlist(%{ "Response" => "Success", "Data" => data }) do
    coins = data
            |> Enum.map(fn { _, coin } ->
                %{
                  id: elem(Integer.parse(coin["Id"]), 0),
                  name: coin["CoinName"],
                  symbol: coin["Name"],
                  image_url: coin["ImageUrl"]
                }
               end)
            |> Enum.sort(&(&1.name <= &2.name))
    {:ok, coins}
  end

  def extract_coins_from_coinlist(_) do
    {:error, %{ reason: :api_error } }
  end
end


alias Cryptofolio.Seeder.CoinList
alias Cryptofolio.Repo
alias Cryptofolio.Dashboard.Trade
alias Cryptofolio.Dashboard.Currency
alias Cryptofolio.Dashboard.CurrencyTick
alias Cryptofolio.Schema.Fiat

require Logger

# Seed cryptocurrencies
with {:ok, req} <- HTTPoison.get("https://www.cryptocompare.com/api/data/coinlist/"),
     {:ok, json} <- Poison.decode(req.body),
     {:ok, coins} <- CoinList.extract_coins_from_coinlist(json) do
  Enum.each(coins, fn coin ->
    changeset = %Currency{name: coin.name, symbol: coin.symbol, cryptocompare_id: coin.id, cryptocompare_image_url: coin.image_url}
    |> Currency.changeset(%{})

    case Repo.insert(changeset) do
      {:ok, _ } -> {:ok}
      {:error, error} -> Logger.error inspect(error)
    end
  end)
else {_, error} ->
  Logger.error "Seed script failed!"
  Logger.error inspect(error)
end

# Seed fiat currencies
root = "https://openexchangerates.org/api/currencies.json"
query = URI.encode_query(app_id: Application.get_env(:cryptofolio, :open_exchange_key))
currencies = "#{root}?#{query}"

with {:ok, req} <- HTTPoison.get(currencies),
     {:ok, currs} <- Poison.decode(req.body) do 
  Enum.each(currs, fn {k, v} ->
    case Repo.insert(Fiat.changeset(%Fiat{name: v, symbol: k}, %{})) do
      {:ok, _ } -> {:ok}
      {:error, error} -> Logger.error inspect(error)
    end
  end)
else {_, error} ->
  Logger.error "Seed script failed!"
  Logger.error inspect(error)
end
