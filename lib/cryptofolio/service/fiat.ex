defmodule Cryptofolio.Schema.Fiat do
  use Ecto.Schema
  import Ecto.Changeset
  alias Cryptofolio.Schema.Fiat

  schema "fiats" do
    field :name, :string
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(%Fiat{} = fiat, attrs) do
    fiat
    |> cast(attrs, [:name, :symbol])
    |> unique_constraint(:name, name: :fiats_name_symbol_index)
    |> validate_required([:name, :symbol])
  end
end
