defmodule Hangman.GameChannel do
  use Phoenix.Channel

  @game_server_name Hangman.GameServer

  def join("games:" <> game_name, _auth_msg, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    broadcast!(socket, "player:joined", %{})
    {:noreply, socket}
  end

  def terminate(_reason, _socket), do: :ok

  def handle_in("new:guess", msg, socket) do
    broadcast!(socket, "new:guess", msg)

    Hangman.GameServer.guess(@game_server_name, msg["letter"])

    broadcast!(socket, "new:state", %{state: Hangman.GameServer.get_state(@game_server_name)})

    {:reply, {:ok, msg}, socket}
  end
end
