defmodule Cryptofolio.Repo.Migrations.CreateCryptofolio.Trade do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add :amount, :decimal
      add :cost, :decimal
      add :date, :naive_datetime
      add :currency_id, references(:currencies)

      timestamps()
    end

    create index(:trades, [:currency_id])
  end
end
