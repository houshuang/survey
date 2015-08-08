defmodule Survey.LiveChannel do
  use Phoenix.Channel
  require Logger
  import Prelude

  def join("live:" <> room, message, socket) do
    room = string_to_int_safe(room)
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, {message, room}})

    {:ok, socket}
  end

  def handle_info({:after_join, {msg, room}}, socket) do
    Logger.info("User entered brainstorming room")

    push socket, "join", %{status: "connected", state: Brainstorm.simple_state(room)}

    {:noreply, assign(socket, :room, room) |> assign(:user, msg["user"])}
  end

  def handle_in("new:op", msg, socket) do
    {diff, id} = Brainstorm.do_op(socket.assigns[:room], socket.assigns[:user], msg)
    broadcast! socket, "new:diff", %{diff: diff, id: id}
    {:reply, :ok, socket}
  end

  def handle_in("get:state", _, socket) do
    state = Brainstorm.simple_state(socket.assigns[:room])
    {:reply, {:ok, %{state: state}}, socket}
  end

  # -------------------------------------------------------------------------
  def handle_in("phx_join", msg, socket) do
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    :ok
  end

end

