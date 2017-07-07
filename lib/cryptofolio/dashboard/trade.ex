defmodule Cryptofolio.Dashboard.Trade.DateTime do
  @behaviour Ecto.Type
  def type, do: :naive_datetime

  def cast(string) when is_binary(string) do
    string = if string =~ " ", do: string, else: string <> " 00:00:00"

    case NaiveDateTime.from_iso8601(string) do
      {:ok, _} = ok -> ok
      {:error, _} -> :error
    end
  end

  def cast(_), do: :error

  def load(term) do
    load_naive_datetime(term)
  end

  defp load_naive_datetime({{year, month, day}, {hour, minute, second, microsecond}}),
    do: {:ok, %NaiveDateTime{year: year, month: month, day: day,
                             hour: hour, minute: minute, second: second, microsecond: {microsecond, 6}}}
  defp load_naive_datetime({{year, month, day}, {hour, minute, second}}),
    do: {:ok, %NaiveDateTime{year: year, month: month, day: day,
                             hour: hour, minute: minute, second: second}}
  defp load_naive_datetime(_),
    do: :error

  def dump(%NaiveDateTime{year: year, month: month, day: day,
                            hour: hour, minute: minute, second: second, microsecond: {microsecond, _}}),
    do: {:ok, {{year, month, day}, {hour, minute, second, microsecond}}}
  def dump(_), do: :error
end

defmodule Cryptofolio.Dashboard.Trade do
  use Ecto.Schema
  import Ecto.Changeset
  alias Cryptofolio.Dashboard.Trade

  @derive {Poison.Encoder, except: [:__meta__, :__schema__, :portfolio]}

  schema "trades" do
    belongs_to :portfolio, Cryptofolio.Portfolio
    belongs_to :currency, Cryptofolio.Dashboard.Currency

    field :amount, :decimal
    field :cost, :decimal
    field :date, Cryptofolio.Dashboard.Trade.DateTime
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(%Trade{} = trade, attrs) do
    trade
    |> cast(attrs, [:amount, :cost, :date, :currency_id, :description])
    |> cast_assoc(:currency)
    |> validate_required([:amount, :cost, :date, :currency_id])
  end
end
