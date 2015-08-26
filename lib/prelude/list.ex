defmodule Prelude.List do

  # turns an array into a map with the index as the key
  def indexify(lst) when is_list(lst) do
    lst
    |> Enum.with_index
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Enum.into(%{})
  end

end
