defmodule StateSync.Room do
  use ExActor.GenServer

  defstart start_link(module, room_id), do: initial_state({module, room_id, apply(module, :init, [])})

  defcall dump, state: state, do: reply(state)

  defcall do_op(op, args), state: {module, room, state} do
    newstate = apply(module, :do_op, [op, args, state])
    set_and_reply({module, room, newstate}, ExDiff.diff(state, newstate))
  end
end
