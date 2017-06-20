defmodule Cryptofolio.Web.MarketcapController do
  require Logger
  use Cryptofolio.Web, :controller

  alias Cryptofolio.Marketcap

  def coin_daily_history(conn, %{ "symbol" => symbol }) do
    with {:ok, history} <- Marketcap.list_coin_daily_history(symbol) do
      conn
      |> render("index.json", history: history)
    else {_, error} ->
      Logger.error inspect(error)
      conn
    end
  end
end
