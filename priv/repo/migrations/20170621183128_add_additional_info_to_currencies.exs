defmodule Cryptofolio.Repo.Migrations.AddAdditionalInfoToCurrencies do
  use Ecto.Migration

  def change do
    alter table(:currencies) do
      add :cryptocompare_image_url, :string
      add :cryptocompare_id, :integer
    end

  end
end
