defmodule Cryptofolio.DashboardTest do
  use Cryptofolio.DataCase

  alias Cryptofolio.Dashboard

  describe "trades" do
    alias Cryptofolio.Dashboard.Trade

    @valid_attrs %{amount: "120.5", cost: "120.5", date: ~N[2010-04-17 14:00:00.000000]}
    @update_attrs %{amount: "456.7", cost: "456.7", date: ~N[2011-05-18 15:01:01.000000]}
    @invalid_attrs %{amount: nil, cost: nil, date: nil}

    def trade_fixture(attrs \\ %{}) do
      {:ok, trade} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboard.create_trade()

      trade
    end

    test "list_trades/0 returns all trades" do
      trade = trade_fixture()
      assert Dashboard.list_trades() == [trade]
    end

    test "get_trade!/1 returns the trade with given id" do
      trade = trade_fixture()
      assert Dashboard.get_trade!(trade.id) == trade
    end

    test "create_trade/1 with valid data creates a trade" do
      assert {:ok, %Trade{} = trade} = Dashboard.create_trade(@valid_attrs)
      assert trade.amount == Decimal.new("120.5")
      assert trade.cost == Decimal.new("120.5")
      assert trade.date == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_trade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_trade(@invalid_attrs)
    end

    test "update_trade/2 with valid data updates the trade" do
      trade = trade_fixture()
      assert {:ok, trade} = Dashboard.update_trade(trade, @update_attrs)
      assert %Trade{} = trade
      assert trade.amount == Decimal.new("456.7")
      assert trade.cost == Decimal.new("456.7")
      assert trade.date == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_trade/2 with invalid data returns error changeset" do
      trade = trade_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboard.update_trade(trade, @invalid_attrs)
      assert trade == Dashboard.get_trade!(trade.id)
    end

    test "delete_trade/1 deletes the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{}} = Dashboard.delete_trade(trade)
      assert_raise Ecto.NoResultsError, fn -> Dashboard.get_trade!(trade.id) end
    end

    test "change_trade/1 returns a trade changeset" do
      trade = trade_fixture()
      assert %Ecto.Changeset{} = Dashboard.change_trade(trade)
    end
  end
end
