defmodule Cryptofolio.Web.TradeView do
  use Cryptofolio.Web, :view

  def format_money(number) do
    Money.parse!(Decimal.to_string(number), :USD)
  end

  def name_with_symbol(c) do
    if c do
      "#{c.name} (#{c.symbol})"
    else
      ""
    end
  end

  def class_for_value(n1) do
    "price-value--#{if Decimal.cmp(n1, Decimal.new(0)) == :lt, do: 'decrease', else: 'increase'}"
  end
end
