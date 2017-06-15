defmodule Cryptofolio.Web.TradeView do
  use Cryptofolio.Web, :view

  def name_with_symbol(c) do
    "#{c.name} (#{c.symbol})"
  end
end
