defmodule Cryptofolio.Repo.Migrations.CreatePortfolio do
  use Ecto.Migration
  import Ecto.Query
  alias Cryptofolio.Repo

  def up do
    create table(:portfolios) do
      add :name, :string

      add :is_public_ratio, :boolean, default: false
      add :is_public_all, :boolean, default: false

      add :user_id, references(:users)

      timestamps()
    end

    flush()

    # generate a portfolio for all users
    users = Repo.all from u in "users", 
                      select: [:private_portfolio, :id, :inserted_at, :updated_at]
    portfolios = Enum.map(users, fn (item) ->
      %{ private_portfolio: p, id: id, inserted_at: i, updated_at: u } = item
      %{
        name: "My Portfolio",
        is_public_ratio: !p,
        is_public_all: !p,
        user_id: id,
        inserted_at: i,
        updated_at: u
      }
    end)
    Repo.insert_all("portfolios", portfolios)

    alter table(:trades) do
      add :portfolio_id, references(:portfolios)
    end

    flush()

    # switch all trades from users to portfolios
    Ecto.Adapters.SQL.query!(Cryptofolio.Repo, """
      UPDATE trades t
      SET portfolio_id = p.id
      FROM users u
      INNER JOIN portfolios p ON p.user_id = u.id
      WHERE t.user_id = u.id
    """, [])

    flush()
    
    # remove stale references
    alter table(:trades) do
      remove :user_id
    end

    alter table(:users) do
      remove :private_portfolio
    end
  end

  def down do
    alter table(:users) do
      add :private_portfolio, :boolean, default: true
    end

    alter table(:trades) do
      add :user_id, references(:users)
    end

    flush()

    # switch all trades from portolios to users
    Ecto.Adapters.SQL.query(Cryptofolio.Repo, """
      UPDATE trades t
      SET user_id = u.id
      FROM users u
      INNER JOIN portfolios p ON p.user_id = u.id
      WHERE t.portfolio_id = p.id
    """)

    flush()

    alter table(:trades) do
      remove :portfolio_id
    end

    drop table(:portfolios)
  end
end
