defmodule Survey.HTML.GridSuggest do

  def grid_select(form, name, id, rows, {min, max, num}) do
    elem_list = 1..String.to_integer(num) 
      |> Enum.to_list
      |> Enum.map(&Integer.to_string/1)

    header = elem_list |> Enum.map(&tdwrap/1)

    header = ["<h3>", name, "</h4><table>", trwrap(["<td></td>", tdwrap(min), header, tdwrap(max)])]
    body = rows 
      |> Enum.with_index 
      |> Enum.map(fn x -> body_row(form, id, x, elem_list) end)
    footer = "</table>"
    IO.iodata_to_binary([header, body, footer])
  end

  def grid_select(form, name, id, rows, elem_list) when is_list(elem_list) do
    header = elem_list |> Enum.map(&tdwrap/1)

    header = ["<h3>", name, "</h3><table>", trwrap(["<td></td><td></td>", header])]
    body = rows |> Enum.map(fn x -> body_row(form, id, x, elem_list) end)
    footer = "</table>"
    IO.iodata_to_binary([header, body, footer])
  end

  defp body_row(form, id, {desc, i}, elem_list) do 
    selname = "#{form}[#{id}.#{[i + ?a]}]"
    sels = elem_list |> Enum.map(&(sel_elem(selname, &1)))
    trwrap([tdwrap(desc), tdwrap(""), sels])
  end

  defp sel_elem(name, val), do: tdwrap(["<input type='radio' name='", name, "' value='", val, "' />"])

  defp tdwrap(x), do: ["<td>", x, "</td>"]
  defp trwrap(x), do: ["<tr>", x, "</tr>"]

end
