# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Cryptofolio.Repo
alias Cryptofolio.Dashboard.Trade
alias Cryptofolio.Dashboard.Currency
alias Cryptofolio.Dashboard.CurrencyTick

if Mix.env == :dev do
  # Any data for development goes here

  currencies = [
    Repo.insert!(%Currency{name: "Ripple", symbol: "XRP"}),
    Repo.insert!(%Currency{name: "Bitcoin", symbol: "XBT"}),
    Repo.insert!(%Currency{name: "Aeon", symbol: "AEON"}),
    Repo.insert!(%Currency{name: "Golem", symbol: "Golem"}),
    Repo.insert!(%Currency{name: "Siacoin", symbol: "SC"})
  ]

  Enum.each(currencies, fn(currency) ->
    Enum.each(1..5, fn(i) ->
      Repo.insert! %CurrencyTick{
        cost_usd: 1 + (i * 5),
        cost_btc: 1 + (i * 5),
        last_updated: Ecto.DateTime.cast!({{2017, 1, 1}, {1, 5 + (i * 5), 0}}),
        currency_id: currency.id
      }
    end)
  end)
end
