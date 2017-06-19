defmodule Cryptofolio.Repo.Migrations.CreateUserTrades do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      add :user_id, references(:users)
    end

    create index(:trades, [:user_id])
  end

end
