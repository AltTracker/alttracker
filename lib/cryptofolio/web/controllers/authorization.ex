defmodule Cryptofolio.Web.AuthorizationController do
  @moduledoc """
  Add authorization check to a controller.
  """
  defmacro __using__(_) do
    quote do
      plug :check_authorized

      defp check_authorized(%{assigns: %{current_user: nil, authorized: false}} = conn, _) do
        conn
        |> put_flash(:error, "Please login to access that page")
        |> redirect(to: session_path(conn, :new))
        |> halt
      end

      defp check_authorized(%{assigns: %{authorized: false}} = conn, _) do
        conn
        |> put_flash(:error, "You are not authorized to do that")
        |> redirect(to: "/")
        |> halt
      end

      defp check_authorized(conn, _) do
        conn
      end
    end
  end
end
