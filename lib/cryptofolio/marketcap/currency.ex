defmodule Cryptofolio.Marketcap.Currency do
  use Ecto.Schema

  schema "currencies" do
    field :name, :string
    field :symbol, :string
    field :cryptocompare_image_id, :integer
    field :cryptocompare_image_url, :string

    timestamps()
  end
end
