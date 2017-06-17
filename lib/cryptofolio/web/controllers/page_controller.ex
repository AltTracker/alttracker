defmodule Cryptofolio.Web.PageController do
  use Cryptofolio.Web, :controller

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      redirect conn, to: trade_path(conn, :index)
    else
      render conn, "index.html"
    end
  end
end
