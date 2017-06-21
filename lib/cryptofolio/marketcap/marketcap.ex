defmodule Cryptofolio.Marketcap.Error do
  defexception reason: nil, id: nil
  @type t :: %__MODULE__{id: reference, reason: any}

  def message(%__MODULE__{reason: reason, id: nil}), do: inspect(reason)
  def message(%__MODULE__{reason: reason, id: id}), do: "[Reference: #{id}] - #{inspect reason}"
end

defmodule Cryptofolio.Marketcap do
  @moduledoc """
  The boundary for the Marketcap system.
  """

  alias Cryptofolio.Marketcap.Error
  def list_coins() do 
    ConCache.get_or_store(:marketcap, :coins, fn () ->
      with {:ok, req} <- HTTPoison.get("https://www.cryptocompare.com/api/data/coinlist/"),
           {:ok, json} <- Poison.decode(req.body),
           {:ok, coins} <- extract_coins_from_coinlist(json) do
        %ConCache.Item{ttl: :timer.hours(24), value: {:ok, coins}}
      else {_, error} ->
        %ConCache.Item{ttl: 0, value: {:error, error}}
      end
    end)
  end

  defp extract_coins_from_coinlist(%{ "Response" => "Success", "Data" => data }) do
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

  defp extract_coins_from_coinlist(_) do
    {:error, :api_error}
  end

  def get_coin_price(symbol \\ "BTC") do
    ConCache.get_or_store(:marketcap, "coin:price##{symbol}", fn () ->
      root = "https://min-api.cryptocompare.com/data/price"
      query = URI.encode_query(fsym: "USD", tsyms: symbol)
      url = "#{root}?#{query}"

      with {:ok, req} <- HTTPoison.get(url),
           {:ok, %{ ^symbol => value }} <- Poison.decode(req.body) do
             %ConCache.Item{ttl: :timer.hours(24), value: Decimal.div(Decimal.new(1), Decimal.new(value))}
      else {_, error} ->
        %ConCache.Item{ttl: 0, value: {:error, error}}
      end
    end)
  end

  def update_coin_prices() do
    root = "https://min-api.cryptocompare.com/data/price"

    with {:ok, coins} <- list_coins() do
      symbols = coins
      |> Enum.pluck(:symbol)

      coins = symbols
      |> (fn(list) -> ["USD" | list] end).()
      |> Enum.join(",")

      query = URI.encode_query(fsym: "USD", tsyms: coins)

      url = "#{root}?#{query}"

      with {:ok, req} <- HTTPoison.get(url),
           {:ok, json} <- Poison.decode(req.body),
           {:ok, data} <- extract_coin_prices_from_api(json) do
        Enum.each(data, fn {k, v} ->
          ConCache.get_or_store(:marketcap, "coin:price##{k}", fn () ->
            Decimal.div(Decimal.new(1), Decimal.new(v))
          end)
        end)
      else {_, error} ->
        %ConCache.Item{ttl: 0, value: {:error, error}}
      end
    else _ ->
      {:error, %Error{reason: :internal_error}}
    end
  end

  defp extract_coin_prices_from_api(%{ "USD" => _ } = data) do
    {:ok, data}
  end

  defp extract_coin_prices_from_api(_) do
    {:error, :api_error}
  end

  def list_coin_daily_history(symbol) do
    ConCache.get_or_store(:marketcap, "coin:history##{symbol}", fn () ->
      root = "https://min-api.cryptocompare.com/data/histohour"
      query = URI.encode_query(fsym: symbol, tsym: "USD", e: "CCCAGG")

      url = "#{root}?#{query}"

      with {:ok, req} <- HTTPoison.get(url),
           {:ok, json} <- Poison.decode(req.body),
           {:ok, history} <- extract_history_from_api(json) do
        %ConCache.Item{ttl: :timer.minutes(5), value: {:ok, %{ticks: history}}}
      else {_, error} ->
        %ConCache.Item{ttl: 0, value: {:error, error}}
      end
    end)
  end

  defp extract_history_from_api(%{ "Response" => "Success", "Data" => data }) do
    {:ok, Enum.map(data, fn history ->
      %{ history | "volumeto" => nil, "volumefrom" => nil }
    end)}
  end

  defp extract_history_from_api(_) do
    {:error, :api_error}
  end
end
