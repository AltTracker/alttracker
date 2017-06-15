defmodule Cryptofolio.Dashboard.CurrencyTick do
  use Ecto.Schema
  import Ecto.Changeset
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
end
