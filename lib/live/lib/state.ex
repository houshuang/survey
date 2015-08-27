defmodule StateSync.State do
  # start by calling init on the module
  # keep the state somewhere - Agent, gen_server, ETS table
  # take in ops, run actions, return updated state
  # write ops to db for persistence (pluggable?)
  # ability to request history as well

  use GenServer

  def init(module) do
    {:ok, {module, apply(module, :init, [])}}
  end

  def handle_call(:dump, _, state) do
    {:reply, state, state}
  end

  def handle_call({:do_op, op, args}, _, {module, state}) do
    newstate = apply(module, :do_op, [op, args, state])
    {:reply, newstate, {module, newstate}}
  end
end
