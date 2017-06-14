defmodule Cryptofolio.Web.TradeControllerTest do
  use Cryptofolio.Web.ConnCase

  alias Cryptofolio.Dashboard

  @create_attrs %{amount: "120.5", cost: "120.5", date: ~N[2010-04-17 14:00:00.000000]}
  @update_attrs %{amount: "456.7", cost: "456.7", date: ~N[2011-05-18 15:01:01.000000]}
  @invalid_attrs %{amount: nil, cost: nil, date: nil}

  def fixture(:trade) do
    {:ok, trade} = Dashboard.create_trade(@create_attrs)
    trade
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, trade_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Trades"
  end

  test "renders form for new trades", %{conn: conn} do
    conn = get conn, trade_path(conn, :new)
    assert html_response(conn, 200) =~ "New Trade"
  end

  test "creates trade and redirects to show when data is valid", %{conn: conn} do
    conn = post conn, trade_path(conn, :create), trade: @create_attrs

    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == trade_path(conn, :show, id)

    conn = get conn, trade_path(conn, :show, id)
    assert html_response(conn, 200) =~ "Show Trade"
  end

  test "does not create trade and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, trade_path(conn, :create), trade: @invalid_attrs
    assert html_response(conn, 200) =~ "New Trade"
  end

  test "renders form for editing chosen trade", %{conn: conn} do
    trade = fixture(:trade)
    conn = get conn, trade_path(conn, :edit, trade)
    assert html_response(conn, 200) =~ "Edit Trade"
  end

  test "updates chosen trade and redirects when data is valid", %{conn: conn} do
    trade = fixture(:trade)
    conn = put conn, trade_path(conn, :update, trade), trade: @update_attrs
    assert redirected_to(conn) == trade_path(conn, :show, trade)

    conn = get conn, trade_path(conn, :show, trade)
    assert html_response(conn, 200)
  end

  test "does not update chosen trade and renders errors when data is invalid", %{conn: conn} do
    trade = fixture(:trade)
    conn = put conn, trade_path(conn, :update, trade), trade: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Trade"
  end

  test "deletes chosen trade", %{conn: conn} do
    trade = fixture(:trade)
    conn = delete conn, trade_path(conn, :delete, trade)
    assert redirected_to(conn) == trade_path(conn, :index)
    assert_error_sent 404, fn ->
      get conn, trade_path(conn, :show, trade)
    end
  end
end
