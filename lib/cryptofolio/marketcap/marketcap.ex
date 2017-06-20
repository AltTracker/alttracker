defmodule Cryptofolio.Marketcap do
  @moduledoc """
  The boundary for the Marketcap system.
  """

  def list_coins() do 
    ConCache.get_or_store(:marketcap, :coins, fn () ->
      req = HTTPoison.get! "https://www.cryptocompare.com/api/data/coinlist/"
      json = Poison.decode! req.body

      %ConCache.Item{ttl: :timer.hours(24), value: extract_coins_from_coinlist(json) }
    end)
  end

  defp extract_coins_from_coinlist(%{ "Response" => "Success", "Data" => data }) do
    Enum.map data, fn { _, coin } ->
      %{ name: coin["CoinName"], symbol: coin["Name"] }
    end
  end

  defp extract_coins_from_coinlist(_) do
    {:error, :api_error}
  end

  def list_coin_daily_history(symbol) do
    root = "https://min-api.cryptocompare.com/data/histohour"
    query = URI.encode_query(fsym: symbol, tsym: "USD", e: "CCCAGG")

    url = "#{root}?#{query}"

    ConCache.get_or_store(:marketcap, url, fn () ->
      with {:ok, req} <- HTTPoison.get(url),
           {:ok, json} <- Poison.decode(req.body),
           {:ok, history} <- extract_history_from_api(json) do
        %ConCache.Item{ttl: :timer.minutes(5), value: {:ok, %{ticks: history}}}
      else _ ->
        %ConCache.Item{ttl: 0, value: {:error, :internal_error}}
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
