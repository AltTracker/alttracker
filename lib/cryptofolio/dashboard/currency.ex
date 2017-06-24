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
    field :cryptocompare_id, :integer
    field :cryptocompare_image_url, :string

    timestamps()
  end

  @doc false
  def changeset(%Currency{} = currency, attrs) do
    currency
    |> cast(attrs, [:name, :symbol, :cryptocompare_id, :cryptocompare_image_url])
    |> unique_constraint(:name, [name: :currencies_name_symbol_index])
    |> validate_required([:name, :symbol])
  end
end
