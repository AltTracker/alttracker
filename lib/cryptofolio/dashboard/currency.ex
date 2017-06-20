defmodule Cryptofolio.Dashboard.Currency do
  use Ecto.Schema
  import Ecto.Changeset
  alias Cryptofolio.Dashboard.Currency

  @derive {Poison.Encoder, except: [:__meta__, :last_tick, :trades, :ticks, :inserted_at, :updated_at]}
  schema "currencies" do
    has_one :last_tick, Cryptofolio.Dashboard.CurrencyTick
    has_many :ticks, Cryptofolio.Dashboard.CurrencyTick
    has_many :trades, Cryptofolio.Dashboard.Trade

    field :name, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(%Currency{} = currency, attrs) do
    currency
    |> cast(attrs, [:name, :symbol, :date])
    |> validate_required([:name, :symbol, :date])
  end
end
