defmodule Survey.RoomChannel do
  use Phoenix.Channel
  require Logger
  alias Survey.ChatPresence
  import Prelude
  alias Survey.Chat

  def join("rooms:" <> room, message, socket) do
    room = string_to_int_safe(room)
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, {message, room}})

    {:ok, socket}
  end

  def handle_info({:after_join, {msg, room}}, socket) do
    broadcast! socket, "user:entered", msg
    Survey.Endpoint.broadcast "admin", "user:entered", %{msg: msg, room: room}
    Logger.info("User entered room")
    ChatPresence.add_user(room, msg, socket)
    users = ChatPresence.get(room)
    previous = Chat.get(room, nil)
    push socket, "join", %{status: "connected", presence: users, previous: previous}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    {room, user} = ChatPresence.remove_user(socket)
    Logger.info("User left room")
    Survey.Endpoint.broadcast "admin", "user:left", %{user: user, room: room}
    broadcast! socket, "user:left", user
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    if msg["body"] != "" do
      time = Ecto.DateTime.to_string(Ecto.DateTime.utc)
      msgstruct = %{
        user: msg["user"], 
        body: msg["body"],
        time: time}
      broadcast! socket, "new:msg", msgstruct
      {room, _} = ChatPresence.get_user(socket)
      Survey.Endpoint.broadcast "admin", "new:msg", %{room: room, msgstruct: msgstruct}
      Survey.Chat.insert(msg, room)
    end
    {:reply, :ok, assign(socket, :user, msg["user"])}
  end

  def handle_in("color", msg, socket) do
    broadcast! socket, "color", msg
    {:reply, :ok, assign(socket, :user, msg["user"])}
  end

end
