defmodule Prelude do
  def string_to_int_safe(y) do
    try do
      String.to_integer(y)
    rescue
      ArgumentError -> 0
      e -> raise e
    end
  end

  def atomify_map(map) do
    Enum.map(map, fn {k,v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

  def append_map(map, key, val) do
    Map.update(map, key, [val], fn x -> List.insert_at(x, 0, val) end)
  end


  # Takes an array of params from a form. Any params of the form steam|A, steam|M 
  # are concatenated into a list, like steam = ["A", "M"], other params are left alone
  def proc_params(x) when is_map(x), do: Enum.reduce(x, %{}, &proc_param/2)

  defp proc_param({sel, ""}, acc), do: acc

  defp proc_param({sel, val}, acc) do
    if String.contains?(sel, "|") do
      [part, rest] = String.split(sel, "|", parts: 2)
      append_map(acc, part, rest)
    else
      Map.put(acc, sel, val) 
    end
  end

end
