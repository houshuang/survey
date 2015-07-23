defmodule Prelude.Map do
  # provide a list of maps, and a list of keys to group by. All maps must
  # have all the gorup_by fields, other fields can vary.
  # for example
  #
  # group_by([%{name: "stian", group: 1, cat: 2},
  #  %{name: "per", group: 1, cat: 1}], [:group, :cat])
  #
  # => %{1 => %{1 => %{cat: 1, group: 1, name: "per"},
  #      2 => %{cat: 2, group: 1, name: "stian"}}}
  def group_by(lst, groups) do
    Enum.reduce(lst, %{}, fn x, acc ->
      extract_and_put(acc, x, groups)
    end)
  end

  defp extract_and_put(map, item, groups) do
    path = Enum.map(groups, fn group -> item[group] end)
    deep_put(map, path, item)
  end

  # put an arbitrarily deep key into an existing map. If a value
  # already exists at that level, it is turned into a list
  # for example:

  # map_deep_put(%{}, [:a, :b, :c], "1")
  # => %{a: %{b: %{c: "1"}}}

  # map_deep_put(%{a: %{b: %{c: "1"}}}, [:a, :b, :c, :d], "2")
  # => %{a: %{b: %{c: [{:d, "2"}, "1"]}}}
  def deep_put(map, path, val, override \\ false) do
    state = {map, []}
    Enum.reduce(path, state, fn x, {acc, cursor} ->
      cursor = [ x | cursor ]
      final = length(cursor) == length(path)
      newval = case get_in(acc, Enum.reverse(cursor)) do
        h when is_list(h) -> [ val | h ]
        nil -> if final, do: val, else: %{}
        h = %{} -> if final, do: [val, h], else: h
        h -> if final, do: [ val, h ], else: [h]
      end
      { put_in(acc, Enum.reverse(cursor), newval), cursor }
    end)
    |> fn x -> elem(x, 0) end.()
  end

end

