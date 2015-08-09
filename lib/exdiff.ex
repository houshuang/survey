defmodule ExDiff do

  def diff(old, new, path \\ "/")

  def diff(old, new, path) when is_map old and is_map new do
    s_old = set(Map.keys(old))
    s_new = set(Map.keys(new))

    removed = HashSet.difference(s_old, s_new)
    |> Enum.map(fn x -> %{ op: "remove", path: path <> inspect(x) } end)

    added = HashSet.difference(s_new, s_old)
    |> Enum.map(fn x -> %{ op: "insert", path: path <> inspect(x), value: new[x] } end)

    same = HashSet.intersection(s_old, s_new)
    |> Enum.map(fn x ->
      if old[x] != new[x], do: diff(old[x], new[x], path <> inspect(x) <> "/")
    end)

    diff = List.flatten([removed, added, same])
    |> Enum.filter(fn x -> !is_nil(x) end)

    diffenc = Poison.encode!(diff)
    newenc = Poison.encode!(new)
    if String.length(diffenc) > String.length(newenc) do
      %{ op: "replace", path: path, value: new }
    else
      diff
    end

  end

  def diff(old, new, path) when is_list(old) and is_list(new) do
    changes = List.zip([old, new])
    |> Enum.with_index
    |> Enum.map(fn {{ old, new }, i} ->
      if old != new, do: diff(old, new, path <> inspect(i) <> "/"), else: []
    end)

    oldlen = length(old)
    newlen = length(new)
    rest = case oldlen do
      x when x > newlen ->
        extra = Enum.with_index(old)
        |> Enum.drop(length(new))
        |> Enum.map(fn {x, i} -> %{ op: "remove", path: path <> inspect(i) } end)
      x when x < newlen ->
        extra = Enum.with_index(new)
        |> Enum.drop(length(old))
        |> Enum.map(fn {x, i} -> %{ op: "insert", path: path <> "-", value: x } end)
      _ -> []
    end

    diff = List.flatten([changes, rest])
    |> Enum.filter(fn x -> !is_nil(x) end)

    diffenc = Poison.encode!(diff)
    newenc = Poison.encode!(new)
    if String.length(diffenc) > String.length(newenc) do
      %{ op: "replace", path: path, value: new }
    else
      diff
    end
 end

  def diff(old, new, path) do
    %{ op: "replace", path: path, value: new }
  end

  def set(lst) do
    Enum.into(lst, HashSet.new)
  end
end

