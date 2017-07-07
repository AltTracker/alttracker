defmodule Cryptofolio.Repo.Migrations.AddActiveToPortfolios do
  use Ecto.Migration

  def change do
    alter table(:portfolios) do
      add :active, :boolean, default: true
    end
  end
end
