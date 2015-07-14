defmodule Survey.Term do
  @behaviour Ecto.Type

  def type, do: :bytea
  def cast(value), do: {:ok, value}
  def blank?(_), do: false

  def load(value) do
    {:ok, :erlang.binary_to_term(value)}
  end

  def dump(value) do
    {:ok, :erlang.term_to_binary(value)}
  end
end


