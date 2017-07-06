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
alias Cryptofolio.Dashboard.Currency
alias Cryptofolio.Schema.Fiat

require Logger

defmodule Cryptofolio.Seeder do
  def seed_cryptocurrencies() do
    with {:ok, req} <- HTTPoison.get("https://www.cryptocompare.com/api/data/coinlist/"),
         {:ok, json} <- Poison.decode(req.body),
         {:ok, coins} <- CoinList.extract_coins_from_coinlist(json) do
      cryptos = Enum.map(coins, fn coin ->
        changeset = %Currency{name: coin.name, symbol: coin.symbol, cryptocompare_id: coin.id, cryptocompare_image_url: coin.image_url}
        |> Currency.changeset(%{})

        case Repo.insert(changeset) do
          {:ok, _ } -> %{ name: coin.name, symbol: coin.symbol }
          {:error, _} -> nil
        end
      end)

      {:ok, cryptos}
    else {_, error} ->
      {:error, error}
    end
  end

  def seed_fiats() do
    root = "https://openexchangerates.org/api/currencies.json"
    query = URI.encode_query(app_id: Application.get_env(:cryptofolio, :open_exchange_key))
    currencies = "#{root}?#{query}"

    with {:ok, req} <- HTTPoison.get(currencies),
         {:ok, currs} <- Poison.decode(req.body) do 
      fiats = Enum.map(currs, fn {k, v} ->
        case Repo.insert(Fiat.changeset(%Fiat{name: v, symbol: k}, %{})) do
          {:ok, _ } -> %{ name: v, symbol: k }
          {:error, _} -> nil 
        end
      end)

      {:ok, fiats}
    else {_, error} ->
      {:error, error}
    end
  end
end

require Logger
cryptos = Cryptofolio.Seeder.seed_cryptocurrencies()
fiats = Cryptofolio.Seeder.seed_fiats()

case cryptos do
  {:ok, cryptocurrencies} ->
    Logger.info "Seeding cryptocurrencies successful"
    Logger.info "Currencies Added:"
    Enum.each Enum.reject(cryptocurrencies, &is_nil/1), fn curr ->
      Logger.info "#{curr.name} (#{curr.symbol})"
    end
  {:error, error} ->
    Logger.error "Seeding cryptocurrencies failed"
    Logger.error error.reason
end

case fiats do
  {:ok, fiats} ->
    Logger.info "Seeding fiats successful"
    Logger.info "Currencies Added:"
    Enum.each Enum.reject(fiats, &is_nil/1), fn curr ->
      Logger.info "#{curr.name} (#{curr.symbol})"
    end
  {:error, error} ->
    Logger.error "Seeding fiats failed"
    Logger.error error.reason
end
