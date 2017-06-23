defmodule Cryptofolio.Web.TradeView do
  use Cryptofolio.Web, :view

  def format_money(number, %{ symbol: symbol, conversion: conversion }) do
    Money.parse!(Decimal.to_string(Decimal.mult(number, Decimal.new(conversion))), symbol)
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
end
