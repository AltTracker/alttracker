defmodule Cryptofolio.Repo.Migrations.CreateCryptofolio.Account.User do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :fiat_id, references(:fiats)
    end

  end
end
