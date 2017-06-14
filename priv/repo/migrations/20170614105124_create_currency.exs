defmodule Cryptofolio.Repo.Migrations.CreateCryptofolio.Currency do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :name, :string
      add :symbol, :string

      timestamps()
    end

    create unique_index(:currencies, [:name, :symbol])
    create index(:currencies, [:symbol])
  end
end
