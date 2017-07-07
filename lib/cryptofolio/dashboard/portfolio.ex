defmodule Cryptofolio.Dashboard.Portfolio do
  use Ecto.Schema
  import Ecto.Changeset
  alias Cryptofolio.Dashboard.Portfolio

  schema "portfolios" do
    belongs_to :user, Cryptofolio.User

    field :name, :string
    field :is_public_ratio, :boolean
    field :is_public_all, :boolean
    field :active, :boolean

    has_many :trades, Cryptofolio.Dashboard.Trade
    timestamps()
  end

  @doc false
  def changeset(model, :deactivate) do
    model
    |> cast(%{ active: false }, [:active])
  end

  def changeset(model, :toggle_privacy) do
    model
    |> cast(%{ is_public_all: !model.is_public_all }, [:is_public_all])
  end

  def changeset(%Portfolio{} = portfolio, attrs) do
    portfolio
    |> cast(attrs, [:name, :is_public_all])
    |> validate_required([:name])
  end
end
