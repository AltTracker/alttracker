defmodule Cryptofolio.Trade do
  def total_cost(%{ cost: cost, amount: amount }) do
    Decimal.mult(cost, amount)
  end

  def current_value(%{ amount: amount, currency: %{ last_tick: last_tick } }) do
    Decimal.mult(amount, last_tick.cost_usd)
  end

  def profit_loss(trade) do
    Decimal.sub(current_value(trade), total_cost(trade))
  end

  def profit_loss_perc(trade) do
    Decimal.mult(Decimal.div(profit_loss(trade), total_cost(trade)), Decimal.new(100))
  end
end
