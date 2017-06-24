defmodule Cryptofolio.Repo.Migrations.AddLowercaseIndexToUsername do
  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :name, :citext
    end
  end

  def down do
    alter table(:users) do
      modify :name, :string
    end
  end
end
