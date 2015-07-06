defmodule Survey.AdminChannel do
  use Phoenix.Channel
  require Logger
  alias Survey.ChatPresence
  import Prelude
  alias Survey.Chat

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
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    :ok
  end

  def handle_in(topic, msg, socket) do
    broadcast! socket, topic, msg
    {:reply, :ok, assign(socket, :user, msg["user"])}
  end
end
