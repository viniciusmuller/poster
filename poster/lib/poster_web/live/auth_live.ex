defmodule PosterWeb.LiveAuth do
  import Phoenix.LiveView

  alias Poster.Accounts
  alias Poster.Accounts.User
  # alias Poster.Router.Helpers, as: Routes

  def on_mount(:require_authenticated_user, _, session, socket) do
    socket = assign_current_user(socket, session)

    case socket.assigns.current_user do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "You have to Sign in to continue")}

      # |> redirect(to: Routes.user_session_path(socket, :new))}

      %User{} ->
        {:cont, socket}
    end
  end

  def on_mount(:fetch_user, _, session, socket) do
    socket = assign_current_user(socket, session)
    {:cont, socket}
  end

  defp assign_current_user(socket, session) do
    case session do
      %{"user_token" => user_token} ->
        assign_new(socket, :current_user, fn ->
          Accounts.get_user_by_session_token(user_token)
          |> Poster.Repo.preload(:author)
        end)

      %{} ->
        assign_new(socket, :current_user, fn -> nil end)
    end
  end
end
