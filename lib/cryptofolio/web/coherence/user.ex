defmodule Cryptofolio.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  use Coherence.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :private_portfolio, :boolean

    belongs_to :fiat, Cryptofolio.Schema.Fiat
    has_many :trades, Cryptofolio.Dashboard.Trade
    coherence_schema()

    timestamps()
  end

  def changeset(model, :toggle_privacy) do
    model
    |> cast(%{ private_portfolio: !model.private_portfolio }, [:private_portfolio])
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email] ++ coherence_fields())
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:name, name: :users_lower_name_index)
    |> validate_coherence(params)
  end

  def changeset(model, params, :profile) do
    model
    |> cast(params, [:fiat_id])
    |> cast_assoc(:fiat)
  end

  def changeset(model, params, :password) do
    model
    |> cast(params, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end
end
