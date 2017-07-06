defmodule Cryptofolio.Web.TradeView do
  use Cryptofolio.Web, :view
  alias Cryptofolio.{Money, Trade}

  def format_money(number, %{ symbol: symbol, conversion: conversion }) do
    amount = Decimal.mult(number, Decimal.new(conversion))

    Money.to_string(amount, symbol)
  end

  def format_money(number) do
    format_money(Decimal.to_string(number), %{ symbol: "USD", conversion: 1 })
  end

  def name_with_symbol(c) do
    if c do
      "#{c.name} (#{c.symbol})"
    else
      ""
    end
  end

  def class_for_sign(n1) do
    "#{if Decimal.cmp(n1, Decimal.new(0)) == :lt, do: 'decrease', else: 'increase'}"
  end

  def class_for_value(n1) do
    "price-value--#{if Decimal.cmp(n1, Decimal.new(0)) == :lt, do: 'decrease', else: 'increase'}"
  end

  def description_preview(description) when is_binary(description) do
    length = String.length(description)

    if length > 50 do
      "#{String.slice(description, 0, 50)}..."
    else
      description
    end
  end

  def description_preview(_) do
    ""
  end

  def privacy_text(private) do
    if private, do: "private", else: "public"
  end

  def required_label(f, name) do
    label f, name do
      [
        "#{humanize(name)}\n",
        content_tag(:abbr, "*", class: "required", title: "required")
      ]
    end
  end

  def required_label(f, name, opts) when is_list(opts) do
    label f, name, opts do
      [
        "#{humanize(name)}\n",
        content_tag(:abbr, "*", class: "required", title: "required")
      ]
    end
  end

  def required_label(f, id, name, opts \\ []) do
    label f, id, opts do
      [
        "#{humanize(name)}\n",
        content_tag(:abbr, "*", class: "required", title: "required")
      ]
    end
  end

  def group_coin_trades(trades) do
    Enum.group_by(trades, &(&1.currency_id))
  end

  def coin_trades_amount(trades) do
    Enum.reduce(trades, Decimal.new(0), fn(trade, acc) -> Decimal.add(trade.amount, acc) end)
  end

  def coin_trades_total_cost(trades) do
    Enum.reduce(trades, Decimal.new(0), fn(trade, acc) -> Decimal.add(trade.total_cost, acc) end)
  end

  def coin_trades_cost(trades) do
    Decimal.div(coin_trades_total_cost(trades), coin_trades_amount(trades))
  end

  def coin_trades_profit_lost(trades) do
    Enum.reduce(trades, Decimal.new(0), fn(trade, acc) -> Decimal.add(Trade.profit_loss(trade), acc) end)
  end

  def coin_trades_profit_lost_perc(trades) do
    total_cost = coin_trades_total_cost(trades)

    if Decimal.cmp(total_cost, Decimal.new(0)) != :eq do
      Decimal.mult(Decimal.div(coin_trades_profit_lost(trades), total_cost), Decimal.new(100))
    else
      Decimal.new(0)
    end

  end
end
