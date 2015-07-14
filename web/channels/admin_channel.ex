defmodule Survey.AdminChannel do
  use Phoenix.Channel
  require Logger
  alias Survey.ChatPresence
  import Prelude
  alias Survey.Chat
  import Prelude

  def join("admin", message, socket) do
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, {message, "admin"}})
    {:ok, socket}
  end

  def handle_info({:after_join, {msg, "admin"}}, socket) do
    Logger.info("User entered admin room")
    room_users = ChatPresence.get_all_users
    push socket, "join", %{status: "connected", room_users: room_users}

    chats = Chat.get_each
    |> Enum.each(fn x -> 
      push socket, "new:msg", %{room: x.room, msgstruct: x} end)
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    :ok
  end

  def handle_in("send:all", msg, socket) do
    room = string_to_int_safe(msg["room"])
    Chat.get(room, nil)
    |> Enum.each(fn x -> 
      push socket, "new:msg", %{room: room, msgstruct: x} end)
    {:reply, :ok, assign(socket, :user, msg["user"])}
  end

  def handle_in(topic, msg, socket) do
    broadcast! socket, topic, msg
    {:reply, :ok, assign(socket, :user, msg["user"])}
  end
end
