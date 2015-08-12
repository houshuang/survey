defmodule Survey.ControlChannel do
  use Phoenix.Channel
  require Logger
  import Prelude
  def join("control", message, socket) do
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join})

    {:ok, socket}
  end

  def handle_info({:after_join, {msg, room}}, socket) do
    push socket, "join", %{status: "connected"}
    push socket, "reload", %{}

    {:noreply}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    :ok
  end

  def handle_in(msg, args, socket) do
    broadcast! socket, msg, args
    {:reply, :ok, socket}
  end

  def handle_in("phx_join", msg, socket) do
    {:noreply, socket}
  end

  def reload do
    Survey.Endpoint.broadcast("control", "reload", %{})
  end
end

