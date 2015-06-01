defmodule Survey.HTML.Survey do
  import MultiDef
  import Survey.HTML.GridSuggest

  def gen_survey(file, form) do
    parse(file)
    |> sectionify
    |> Enum.with_index
    |> Enum.map(fn x -> do_section(x, form) end)
    |> IO.iodata_to_binary
    |> Phoenix.HTML.raw
  end

  def do_section({seq, i}, form) do
    content = Enum.map(seq, fn(x) -> gen_elements(x, form) end)
    display = if i == 0, do: "", else: "display: none"
    ["<div class='block' style='#{display}'><h1>Section #{i + 1}</h1>",content, "<hr><div class='stepsController next right'><a href='#'>Next</a></div> </div>"]
  end

  mdef gen_elements do
    {:header, txt}, _                         -> ["<h3>", txt, "</h3>"]
    %{type: "text"} = h, form                 -> fs ["<h4>", h.name, ": </h4><input name='#{form}[#{h.number}]' type=text><br>"]
    %{type: "radio"} = h, form                -> fs multi(form, h, "radio")
    %{type: "multi"} = h, form                -> fs multi(form, h, "checkbox")
    %{type: "textbox"} = h, form              -> fs ["<h4>", h.name, ": </h4>", "<textarea name='#{form}[#{h.number}]'></textarea><p>"]
    %{type: "grid", choicerange: _} = h, form -> fs grid_select(form, h.name, h.number, h.rows, List.to_tuple(h.choicerange))
    %{type: "grid", choices: _} = h, form     -> fs grid_select(form, h.name, h.number, h.rows, h.choices)
    :section, _ -> ""
  end

  def fs(x), do: ["<fieldset>", x, "</fieldset>"]

  def multi(form, h, type) do
    opts = h.options
    |> Enum.with_index
    |> Enum.map(
      fn {x, i} -> 
        case type do
          "checkbox" -> ["<label><input name='#{form}[#{h.number}.#{[?a + i]}]' value='true' type=checkbox><span>", 
            x, "</span></label>"]
          "radio" -> ["<label><input name='#{form}[#{h.number}]' value='#{[?a + i]}' type=radio><span>", 
            x, ": </span></label>"]
        end
      end)

    ["<h4>", h.name, "</h4>", opts]
  end

  #================================================================================ 

  def parse(file) do
    File.stream!(file)
    |> Stream.filter(&remove_blank_lines/1)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&classify_line_types/1)
    |> concat_blocks
  end
  
  def remove_blank_lines(x), do: String.strip(x) != ""

  mdef classify_line_types do
    "#"<>rest     -> {:header, rest}
    " "<>rest     -> {:sub, rest}
    "\t"<>rest    -> {:sub, rest}
    "choices"     -> :choices
    "choicerange" -> :choicerange
    "rows"        -> :rows
    "section"     -> :section
    "meta"        -> :meta
    rest          -> [type, q] = String.split(rest, ",", parts: 2); {:question, type, String.strip(q)}
  end

  def concat_blocks(x) do
    Enum.reduce(x, {:wait, 1, []}, &concat_blocks_proc/2)
    |> elem(2)
    |> Enum.reverse
  end

  mdef concat_blocks_proc do
    :meta, {_, num, acc}                      -> {:meta, num, acc}
    :choicerange, {_, num, acc}               -> {:choicerange, num, acc}
    :rows, {_, num, acc}                      -> {:rows, num, acc}
    :choices, {_, num, acc}                   -> {:choices, num, acc}
    {:question, "multi", name}, {_, num, acc} -> {:options, num + 1, [ %{name: name, number: num, type: "multi"} | acc]}
    {:question, "radio", name}, {_, num, acc} -> {:options, num + 1, [ %{name: name, number: num, type: "radio"} | acc]}

    {:question, type, name}, {_, num, acc}    -> {:wait, num + 1, [ %{name: name, number: num, type: type} | acc]}
    {:header, _} = h, {_, num, acc}           -> {:wait, num, [h | acc]}

    :section, {_, num, acc}                   -> {:wait, num, [:section | acc]}

    {:sub, str}, {:meta, num, [h | tl] }      -> { :meta, num, [ map_merge(h, :meta, proc_meta( str )) | tl ] }
    {:sub, str}, {elem, num, [h | tl] }       -> { elem, num, [ append_in(h, elem, str) | tl ] }
  end

  def proc_meta(str) do
    [k, v] = String.split(str, "=", parts: 2)
    |> Enum.map(&String.strip/1)
    Map.put(%{}, k, v)
  end

  # takes a list like [1, 2, 3, :section, 4, 5, 6, :section, 8, 9] and
  # creates a set of nested lists: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  mdef sectionify do
    seq                  -> sectionify seq, [[]]
    [:section | tl], acc -> sectionify tl, [[] | acc]
    [h | t], [h2 | t2]   -> sectionify t, [ List.insert_at(h2, 999, h) | t2 ]
    [], acc              -> Enum.reverse acc
  end

  def append_in(h, elem, str), do: Map.update(h, elem, [str], fn x -> List.insert_at(x, 999, str) end)
  def map_merge(h, elem, kv), do: Map.update(h, elem, kv, fn x -> Map.merge(x, kv) end)

end
