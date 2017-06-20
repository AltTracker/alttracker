defmodule Cryptofolio.Web.MarketcapView do
  use Cryptofolio.Web, :view

  def render("index.json", %{history: history}) do
    history
  end
end
