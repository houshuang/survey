defmodule Survey.BrainstormChannel do
  use Phoenix.Channel
  require Logger
  import Prelude
  #
  #
  # maintain separate state for each SIG
  # write to db regularly
  # list of ideas. id, title, votes, date, added_by. sorted by votes on display.
  # each idea has list of comments. date, added_by
  # user_specific states: which ideas already voted
  # app_specific state (not transmitted): adding_comment flag for each idea. (comments are not threaded)
  #
  #
  #
  def join("brainstorm:" <> room, message, socket) do
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

  def handle_info(:ping, socket) do
    push socket, "ping", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    :ok
  end

  def handle_in("new:op", msg, socket) do
    state = Brainstorm.do_op(socket.assigns[:room], socket.assigns[:user], msg)
    broadcast! socket, "new:state", %{state: state}
    {:reply, :ok, socket}
  end

  def handle_in("phx_join", msg, socket) do
    {:noreply, socket}
  end
end
