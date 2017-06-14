defmodule Cryptofolio.Dashboard.Currency do
  use Ecto.Schema
  import Ecto.Changeset
  alias Cryptofolio.Dashboard.Currency


  schema "currencies" do
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
