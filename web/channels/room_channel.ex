defmodule Survey.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("rooms:lobby", message, socket) do
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, message})

    {:ok, socket}
  end
  def join("rooms:" <> private_subtopic, message, socket) do
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, message})

    {:ok, socket}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end
  def handle_in("heartbeat", msg, socket) do
    IO.inspect([:heartbeat, socket])
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, {:ok, %{msg: msg["body"]}, assign(socket, :user, msg["user"])}}
  end
end
