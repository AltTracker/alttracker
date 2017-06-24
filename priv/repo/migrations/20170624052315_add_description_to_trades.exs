defmodule Cryptofolio.Repo.Migrations.AddDescriptionToTrades do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      add :description, :text
    end

  end
end
