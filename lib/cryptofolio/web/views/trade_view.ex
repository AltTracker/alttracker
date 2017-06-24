defmodule Cryptofolio.Web.TradeView do
  use Cryptofolio.Web, :view
  alias Cryptofolio.Money

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

  def description_preview(description) do
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

  def required_label(f, name, opts) do
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
end
