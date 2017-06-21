# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

defmodule Cryptofolio.Seeder.CoinList do
  def extract_coins_from_coinlist(%{ "Response" => "Success", "Data" => data }) do
    coins = data
            |> Enum.map(fn { _, coin } ->
                %{
                  id: coin["Id"],
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

require Logger

with {:ok, req} <- HTTPoison.get("https://www.cryptocompare.com/api/data/coinlist/"),
     {:ok, json} <- Poison.decode(req.body),
     {:ok, coins} <- CoinList.extract_coins_from_coinlist(json) do
  Enum.each(coins, fn coin ->
    Repo.insert!(%Currency{name: coin.name, symbol: coin.symbol})
  end)
else {_, error} ->
  Logger.error "Seed script failed!"
  Logger.error inspect(error)
end
