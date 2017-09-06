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

  use GenServer

  alias Cryptofolio.Repo
  alias Cryptofolio.Marketcap.Currency

  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work(:timer.seconds(1))
    {:ok, state}
  end

  def handle_info(:work, state) do
    case update_coin_prices() do
      {:error} -> schedule_work(:timer.seconds(1))
      _ -> schedule_work(:timer.minutes(5))
    end

    {:noreply, state}
  end

  defp schedule_work(timer) do
    Process.send_after(self(), :work, timer)
  end

  def list_fiats() do 
    ConCache.get_or_store(:marketcap, :fiats, fn () ->
      root = "https://openexchangerates.org/api/currencies.json"
      query = URI.encode_query(app_id: Application.get_env(:cryptofolio, :open_exchange_key))
      currencies = "#{root}?#{query}"

      with {:ok, req} <- HTTPoison.get(currencies),
           {:ok, currs} <- Poison.decode(req.body) do 
           %ConCache.Item{ttl: :timer.hours(24), value: currs}
      else {_, error} ->
        %ConCache.Item{ttl: 1, value: {:error, error}}
      end
    end)
  end

  def get_fiat_price(symbol \\ "USD") do
    fiats = ConCache.get_or_store(:marketcap, "fiat:prices", fn () ->
      root = "https://openexchangerates.org/api/latest.json"
      query = URI.encode_query(app_id: Application.get_env(:cryptofolio, :open_exchange_key))
      url = "#{root}?#{query}"

      with {:ok, req} <- HTTPoison.get(url),
           {:ok, %{ "rates" => rates }} <- Poison.decode(req.body) do
        %ConCache.Item{ttl: :timer.hours(24), value: {:ok, rates}}
      else {_, error} ->
        %ConCache.Item{ttl: 1, value: {:error, error}}
      end
    end)

    with {:ok, value} <- fiats,
         true <- Map.has_key?(value, symbol) do
      {:ok, value[symbol]}
    else _ ->
      {:error, %{ reason: "Can't find FIAT price" }}
    end
  end

  def list_coins() do 
    Currency |> Repo.all
  end

  def get_coin_price(symbol \\ "BTC") do
    ConCache.get_or_store(:marketcap, "coin:price##{symbol}", fn () ->
      root = "https://min-api.cryptocompare.com/data/price"
      query = URI.encode_query(fsym: "USD", tsyms: symbol)
      url = "#{root}?#{query}"

      with {:ok, req} <- HTTPoison.get(url),
           {:ok, %{ ^symbol => value }} <- Poison.decode(req.body) do
             %ConCache.Item{ttl: :timer.minutes(5), value: Decimal.div(Decimal.new(1), Decimal.new(value))}
      else {_, error} ->
        %ConCache.Item{ttl: 1, value: {:error, error}}
      end
    end)
  end

  def update_coin_prices() do
    Logger.info "Updating Coin Prices"
    root = "https://min-api.cryptocompare.com/data/price"

    symbols = list_coins()
    |> Enum.map(& &1.symbol)

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
          %ConCache.Item{ttl: :timer.minutes(5), value: Decimal.div(Decimal.new(1), Decimal.new(v))}
        end)
      end)
    else {_, error} ->
      {:error, error}
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
        %ConCache.Item{ttl: 1, value: {:error, error}}
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
