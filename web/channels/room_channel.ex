defmodule Survey.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Survey.ChatPresence

  def join("rooms:" <> room, message, socket) do
    IO.inspect(message)
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, {message, room}})

    {:ok, socket}
  end

  def handle_info({:after_join, {msg, room}}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    ChatPresence.add_user(room, msg["user"], socket)
    users = ChatPresence.get(room)
    push socket, "join", %{status: "connected", presence: users}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    user = ChatPresence.remove_user(socket)
    broadcast! socket, "user:left", %{user: user}
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, :ok, assign(socket, :user, msg["user"])}
  end
end
