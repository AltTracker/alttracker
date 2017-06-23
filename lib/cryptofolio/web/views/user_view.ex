defmodule Cryptofolio.Web.UserView do
  use Cryptofolio.Web, :view

  def name_with_symbol(%{ name: name, symbol: symbol}) do
    "#{name} (#{symbol})"
  end

  def name_with_symbol(_) do
    ""
  end
end
