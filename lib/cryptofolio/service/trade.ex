defmodule Cryptofolio.Trade do
  def filter_valid(trades) do
    Enum.filter(trades, fn(trade) -> Kernel.elem(trade.currency.cost_usd, 0) === :ok end)
  end

  def is_valid(trade) do
    Kernel.elem(trade.currency.cost_usd, 0) === :ok
  end

  def normalize_cost(trades) do
    Enum.map(trades, fn (trade) -> %{ trade | currency: %{ trade.currency | cost_usd: Kernel.elem(trade.currency.cost_usd, 0) } } end)
  end

  def drop_ticks(trades) when is_list(trades) do
    # XXX: There ought to be a way for Poison to encode
    # conditionally (ticks needed in pie chart, not needed in line chart)
    Enum.map(trades, &drop_ticks/1)
  end

  def drop_ticks(trade) do
    map = trade
    |> Map.from_struct
    |> Map.drop([:__meta__, :__struct__, :currencies, :user, :portfolio])
    currency = map.currency
    |> Map.from_struct
    |> Map.drop([:__meta__, :__struct__])

    %{ map | currency: Map.drop(currency, [:ticks, :trades]) }
  end

  def total_cost(%{ cost: cost, amount: amount }) do
    Decimal.mult(cost, amount)
  end

  def total_cost(%{ total_cost: total_cost }) do
    total_cost
  end

  def current_value(%{ amount: amount, currency: %{ cost_usd: cost_usd } }) do
    case cost_usd do
      {:ok, value} -> Decimal.mult(amount, value)
      _ -> Decimal.new(0)
    end
  end

  def current_value(%{ current_value: current_value }) do
    current_value
  end

  def profit_loss(trade) do
    Decimal.sub(current_value(trade), total_cost(trade))
  end

  def profit_loss(value, cost) do
    profit_loss(%{ current_value: value, total_cost: cost })
  end

  def profit_loss_perc(trade) do
    total_cost = total_cost(trade)

    if Decimal.cmp(total_cost, Decimal.new(0)) != :eq do
      Decimal.mult(Decimal.div(profit_loss(trade), total_cost), Decimal.new(100))
    else
      Decimal.new(0)
    end
  end

  def profit_loss_perc(value, cost) do
    profit_loss_perc(%{ current_value: value, total_cost: cost })
  end
end
