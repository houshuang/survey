defmodule Prelude.Atom do
  # converts atoms to strings, leaving existing strings alone
  def to_string(x) when is_atom(x), do: Atom.to_string(x)
  def to_string(x) when is_binary(x), do: x
end
