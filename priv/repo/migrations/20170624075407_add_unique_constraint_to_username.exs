defmodule Cryptofolio.Repo.Migrations.AddUniqueConstraintToUsername do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext"
    execute "CREATE UNIQUE INDEX users_lower_name_index ON users (LOWER(name))"
  end

  def down do
    execute "DROP EXTENSION citext"
    execute "DROP INDEX users_lower_name_index"
  end
end
