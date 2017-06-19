defimpl Canada.Can, for: Cryptofolio.User do
  alias Cryptofolio.User
  alias Cryptofolio.Dashboard.Trade

  def can?(%User{id: user_id}, action, %User{id: user_id}) when action in ~w(show edit update), do: true
  def can?(%User{id: user_id}, action, Trade) when action in ~w(index new create)a, do: true
  def can?(%User{id: user_id}, _, %Trade{user_id: user_id}), do: true

  def can?(_, _, _), do: false
end

defimpl Canada.Can, for: Atom do
  def can?(_, _, _), do: false
end
