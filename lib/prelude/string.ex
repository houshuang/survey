defmodule Prelude.String do

  def to_int_safe(y) do
    try do
      case y do
        y when is_integer(y) -> y
        y when is_binary(y) -> String.to_integer(y)
        nil -> 0
      end
    rescue
      ArgumentError -> 0
      e -> raise e
    end
  end

  def is_integer?(str) do
    case Integer.parse(str) do
      {_, ""} -> true
      _       -> false
    end
  end

end
