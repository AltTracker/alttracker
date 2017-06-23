defmodule Cryptofolio.Repo.Migrations.CreateFiat do
  use Ecto.Migration

  def change do
    create table(:fiats) do
      add :name, :string
      add :symbol, :string

      timestamps()
    end

    create unique_index(:fiats, [:name, :symbol])
    create index(:fiats, [:symbol])
  end
end
