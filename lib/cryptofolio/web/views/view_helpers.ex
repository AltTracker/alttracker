defmodule Cryptofolio.Web.ViewHelpers do
  @moduledoc """
  Conveniences for views
  """
  use Phoenix.HTML
  alias Cryptofolio.Money

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

  def format_money(number, %{ symbol: symbol, conversion: conversion }) do
    amount = Decimal.mult(number, Decimal.new(conversion))

    Money.to_string(amount, symbol)
  end

  def format_money(number) do
    format_money(Decimal.to_string(number), %{ symbol: "USD", conversion: 1 })
  end


  def name_with_symbol(%{name: name, symbol: symbol}) do
    "#{name} (#{symbol})"
  end

  def name_with_symbol() do
    ""
  end
end
