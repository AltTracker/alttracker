defmodule Cryptofolio.Repo.Migrations.CreateCurrencyTick do
  use Ecto.Migration

  def change do
    create table(:currency_ticks) do
      add :cost_usd, :decimal
      add :cost_btc, :decimal
      add :last_updated, :naive_datetime
      add :currency_id, references(:currencies)
    end

    create unique_index(:currency_ticks, [:currency_id, :last_updated])
    create index(:currency_ticks, [:currency_id])
  end
end
