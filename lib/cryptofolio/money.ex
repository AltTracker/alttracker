# Inspired by liuggio's money module
# at time of writing, the module doesn't support custom currencies
# which is needed by Cryptofolio
defmodule Cryptofolio.Money do
  @symbols %{
    "AED": "AED",
    "AFN": "Af",
    "ALL": "ALL",
    "AMD": "AMD",
    "ARS": "AR$",
    "AUD": "AU$",
    "AZN": "man.",
    "BAM": "KM",
    "BDT": "Tk",
    "BGN": "BGN",
    "BHD": "BD",
    "BIF": "FBu",
    "BND": "BN$",
    "BOB": "Bs",
    "BRL": "R$",
    "BWP": "BWP",
    "BYR": "BYR",
    "BZD": "BZ$",
    "CAD": "CA$",
    "CDF": "CDF",
    "CHF": "CHF",
    "CLP": "CL$",
    "CNY": "CN¥",
    "COP": "CO$",
    "CRC": "₡",
    "CVE": "CV$",
    "CZK": "Kč",
    "DJF": "Fdj",
    "DKK": "Dkr",
    "DOP": "RD$",
    "DZD": "DA",
    "EEK": "Ekr",
    "EGP": "EGP",
    "ERN": "Nfk",
    "ETB": "Br",
    "EUR": "€",
    "GBP": "£",
    "GEL": "GEL",
    "GHS": "GH₵",
    "GNF": "FG",
    "GTQ": "GTQ",
    "HKD": "HK$",
    "HNL": "HNL",
    "HRK": "kn",
    "HUF": "Ft",
    "IDR": "Rp",
    "ILS": "₪",
    "INR": "Rs",
    "IQD": "IQD",
    "IRR": "IRR",
    "ISK": "Ikr",
    "JMD": "J$",
    "JOD": "JD",
    "JPY": "¥",
    "KES": "Ksh",
    "KHR": "KHR",
    "KMF": "CF",
    "KRW": "₩",
    "KWD": "KD",
    "KZT": "KZT",
    "LBP": "LB£",
    "LKR": "SLRs",
    "LTL": "Lt",
    "LVL": "Ls",
    "LYD": "LD",
    "MAD": "MAD",
    "MDL": "MDL",
    "MGA": "MGA",
    "MKD": "MKD",
    "MMK": "MMK",
    "MOP": "MOP$",
    "MUR": "MURs",
    "MXN": "MX$",
    "MYR": "RM",
    "MZN": "MTn",
    "NAD": "N$",
    "NGN": "₦",
    "NIO": "C$",
    "NOK": "Nkr",
    "NPR": "NPRs",
    "NZD": "NZ$",
    "OMR": "OMR",
    "PAB": "B/.",
    "PEN": "S/.",
    "PHP": "₱",
    "PKR": "PKRs",
    "PLN": "zł",
    "PYG": "₲",
    "QAR": "QR",
    "RON": "RON",
    "RSD": "din.",
    "RUB": "RUB",
    "RWF": "RWF",
    "SAR": "SR",
    "SDG": "SDG",
    "SEK": "Skr",
    "SGD": "S$",
    "SOS": "Ssh",
    "SYP": "SY£",
    "THB": "฿",
    "TND": "DT",
    "TOP": "T$",
    "TRY": "TL",
    "TTD": "TT$",
    "TWD": "NT$",
    "TZS": "TSh",
    "UAH": "₴",
    "UGX": "USh",
    "USD": "$",
    "UYU": "$U",
    "UZS": "UZS",
    "VEF": "Bs.F.",
    "VND": "₫",
    "XAF": "FCFA",
    "XOF": "CFA",
    "YER": "YR",
    "ZAR": "R",
    "ZMK": "ZK"
  }

  def to_string(amount, symbol) do
    symbol = get_symbol(symbol)
    number = format_number(amount)
    sign = if Decimal.cmp(amount, Decimal.new(0)) == :lt, do: "-"

    [sign, symbol, number] |> Enum.join |> String.lstrip
  end

  defp format_number(amount) do
    delimeter = "."
    separator = ","
    exponent = 2

    [super_unit | sub_unit] = amount
                              |> Decimal.abs
                              |> Decimal.round(exponent)
                              |> Decimal.to_string()
                              |> String.split(".")
    super_unit = super_unit |> reverse_group(3) |> Enum.join(separator)

    [super_unit, sub_unit] |> Enum.join(delimeter)
  end

  defp reverse_group(str, count) when is_binary(str) do
    reverse_group(str, Kernel.abs(count), [])
  end
  defp reverse_group("", _count, list) do
    list
  end
  defp reverse_group(str, count, list) do
    {first, last} = String.split_at(str, -count)
    reverse_group(first, count, [last | list])
  end

  defp get_symbol(symbol) do
    key = String.to_atom(symbol)

    if Map.has_key?(@symbols, key) do
      Map.get(@symbols, key)
    else
      symbol
    end
  end
end
