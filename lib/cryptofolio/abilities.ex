defimpl Canada.Can, for: Cryptofolio.User do
  alias Cryptofolio.User
  alias Cryptofolio.Dashboard.Trade
  alias Cryptofolio.Dashboard.Portfolio

  def can?(%User{id: user_id}, action, %User{id: user_id}) when action in ~w(edit update), do: true

  def can?(%User{id: user_id}, action, %Portfolio{user_id: user_id}) when action in ~w(new create edit update delete)a, do: true

  def can?(%User{id: user_id}, action, %Trade{}) when action in ~w(new)a, do: true
  def can?(user, action, trade = %Trade{}) do
    trade.portfolio.user_id == user.id
  end

  def can?(_, _, _), do: false
end

defimpl Canada.Can, for: Atom do
  def can?(_, _, _), do: false
end
