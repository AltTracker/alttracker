defmodule Cryptofolio.Dashboard.CurrencyTick do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cryptofolio.Dashboard.CurrencyTick
  alias Cryptofolio.Dashboard.Trade

  schema "currency_ticks" do
    belongs_to :currency, Cryptofolio.Dashboard.Currency

    field :cost_usd, :decimal
    field :cost_btc, :decimal
    field :last_updated, Ecto.DateTime
  end

  @doc false
  def changeset(%Trade{} = trade, attrs) do
    trade
    |> cast(attrs, [:cost_usd, :cost_btc, :last_updated])
    |> cast_assoc(:currency)
    |> validate_required([:cost_usd, :cost_btc, :last_updated, :currency_id])
  end

  def to_unix_time(datetime) do
    datetime
    |> Ecto.DateTime.to_erl
    |> :calendar.datetime_to_gregorian_seconds
    |> Kernel.-(62167219200)
  end

  defimpl Poison.Encoder, for: CurrencyTick do
    def encode(tick, options) do
      tick = %CurrencyTick{
        tick | last_updated: CurrencyTick.to_unix_time(tick.last_updated)
      }
      Poison.Encoder.Map.encode(Map.take(tick, [:cost_usd, :cost_btc, :last_updated]), options)
    end
  end
end
