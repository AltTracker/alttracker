defmodule Cryptofolio.Web.UserController do
  use Cryptofolio.Web, :controller

  import Ecto.Query, warn: false

  alias Coherence.Config
  alias Cryptofolio.Account

  require Ecto.Query

  def edit(conn, _) do
    user = conn.assigns[:current_user]
    changeset = Account.change_user(user)
    fiats = Account.list_fiats()
    render(conn, "edit.html", user: user, changeset: changeset, fiats: fiats)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns[:current_user]

    case Account.update_user(user, user_params) do
      {:ok, user} ->
        apply(Config.auth_module, Config.update_login, [conn, user, [id_key: Config.schema_key]])

        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :edit))
      {:error, %Ecto.Changeset{} = changeset} ->
        fiats = Account.list_fiats()
        render(conn, "edit.html", user: user, changeset: changeset, fiats: fiats)
    end
  end
end
