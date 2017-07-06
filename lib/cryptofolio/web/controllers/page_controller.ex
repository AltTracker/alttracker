defmodule Cryptofolio.Web.PageController do
  use Cryptofolio.Web, :controller
  alias Coherence.Config
  alias Coherence.ControllerHelpers, as: Helpers

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      redirect conn, to: trade_path(conn, :index)
    else
      user_schema = Config.user_schema
      cs = Helpers.changeset(:registration, user_schema, user_schema.__struct__)
      changelog = "priv/CHANGELOG.md"
                  |> File.read!
                  |> Earmark.as_html!

      conn
      |> put_layout("home.html")
      |> render("index.html", email: "", changeset: cs, changelog: changelog)
    end
  end

  def about(conn, _params) do
    conn
    |> render("about.html")
  end
end
