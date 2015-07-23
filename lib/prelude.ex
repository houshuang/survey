defmodule Prelude do
  import Ecto.Query
  require Ecto.Query

  def safe_encode_base64(str) do
    Base.encode64(str)
    |> String.replace("+", "-")
    |> String.replace("/", "_")
    |> String.replace("=", ".")
  end

  def string_to_int_safe(y) do
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

  def atomify_map(map) do
    Enum.map(map, fn {k,v} -> {safe_to_atom(k), v} end)
    |> Enum.into(%{})
  end

  def stringify_map(map) do
    Enum.map(map, fn {k,v} -> {safe_to_string(k), v} end)
    |> Enum.into(%{})
  end

  def safe_to_atom(x) when is_atom(x), do: x
  def safe_to_atom(x) when is_binary(x), do: String.to_atom(x)
  def safe_to_string(x) when is_atom(x), do: Atom.to_string(x)
  def safe_to_string(x) when is_binary(x), do: x


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


  def indexify(lst) when is_list(lst) do
    lst
    |> Enum.with_index
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Enum.into(%{})
  end

  def char_to_num(ch) do
    %{"a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4, "f" => 5,
    "g" => 6, "h" => 7, "i" => 8, "j" => 9, "k" => 10, "l" => 11, "m" => 12,
    "n" => 13, "o" => 14, "p" => 15, "q" => 16, "r" => 17, "s" => 18, "t" => 19,
    "u" => 20, "v" => 21, "w" => 22, "x" => 23, "y" => 24, "z" => 25}[ch]
  end

  def get_file_list(path) do
    Path.wildcard("data/#{path}/*.txt")
    |> Enum.map(fn x -> {extract_num(x), File.read!(x)} end)
  end

  def extract_num(x) do
    Path.basename(x, ".txt")
    |> string_to_int_safe
  end

  def html_to_freq(html) do
    html
    |> String.replace("<", " <")
    |> Floki.text
    |> (fn x -> Regex.replace(~r/[()\[\\\/]"'.,;:-_=?!]/, x, "") end).()
    |> String.split(" ")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end

  def ok({:ok, x}), do: x
  def ok(y), do: raise y

end
