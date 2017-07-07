defmodule Cryptofolio.Dashboard.Portfolio do
  use Ecto.Schema
  import Ecto.Changeset
  alias Cryptofolio.Dashboard.Portfolio

  schema "portfolios" do
    belongs_to :user, Cryptofolio.User

    field :name, :string
    field :is_public_ratio, :boolean
    field :is_public_all, :boolean

    has_many :trades, Cryptofolio.Dashboard.Trade
    timestamps()
  end

  @doc false
  def changeset(%Portfolio{} = portfolio, attrs) do
    portfolio
    |> cast(attrs, [:user])
    |> cast_assoc(:user)
    |> validate_required([:user])
  end
end
