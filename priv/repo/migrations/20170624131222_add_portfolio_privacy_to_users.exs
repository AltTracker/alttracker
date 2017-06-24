defmodule Cryptofolio.Repo.Migrations.AddPortfolioPrivacyToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :private_portfolio, :boolean, default: true
    end
  end
end
