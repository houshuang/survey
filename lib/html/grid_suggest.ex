defmodule Survey.HTML.GridSuggest do

  def grid_select(form, name, id, rows, elem_list) do
    if is_tuple(elem_list) do
      {min, max, num} = elem_list
      elems = List.flatten [min, List.duplicate("", String.to_integer(num) - 2), max] 
      labels = Enum.to_list(1..length(elems)) |> Enum.map(&Integer.to_string/1)
    else
      elems = elem_list
      labels = elem_list
    end

    headercells = elems |> Enum.map(fn x -> ["<div class='cell'>", x, "</div>"] end)

    header = ["<h4>", name, "</h4><div class='evaluation table'><div class='line answers'><div class='cell exception'></div>", headercells, "</div>"]
    body = rows |> Enum.with_index |> Enum.map(fn x -> body_row(form, id, x, labels) end) 
    footer = "</table>"
    IO.iodata_to_binary([header, body, footer])
  end

  defp body_row(form, id, {desc, i}, elem_list) do 
    selname = "#{form}[#{id}.#{[i + ?a]}]"
    sels = elem_list |> Enum.map(&(sel_elem(selname, &1)))
    ["<div class='line'> <div class='cell question'>", desc, "</div>", sels, "</div>"]
  end

  defp sel_elem(name, val) do
    ["<div class='cell answer'> <label> <input type='radio' name='", name, "' value='", val, "'> <span>", val, "</span> </label> </div>"]
  end

end
