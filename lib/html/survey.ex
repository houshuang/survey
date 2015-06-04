defmodule Survey.HTML.Survey do
  import MultiDef

  #--------------------------------------------------------------------------------
  # main pipeline
  
  def gen_survey(file, form) do
    parse(file)
    |> sectionify
    |> Enum.with_index
    |> proc_sections(form)
    |> IO.iodata_to_binary
  end

  #--------------------------------------------------------------------------------
  # sections

  # only print section headers if more than one section
  def proc_sections([{seq, 0}], form), do: do_section({seq, 0}, form, :single)
  def proc_sections(seqs, form), do: seqs |> Enum.map(fn x -> do_section(x, form, :many) end)

  def do_section({seq, i}, form, many) do
    content = Enum.map(seq, fn(x) -> gen_elements(x, form) end)
    display = if i == 0, do: "", else: "display: none"
    sectionheader = case many do
      :single -> ""
      :many   -> "<h1>Section #{i + 1}</h1>"
    end

    ["<div class='block' style='#{display}'>", sectionheader, content, 
      "<hr></div>"]
  end

  #--------------------------------------------------------------------------------
  # elements

  mdef gen_elements do
    {:header, txt}, _ -> ["<h3>", txt, "</h3>"]
    {:para, txt}, _   -> ["<p>", txt, "</p>"]
    h, form           -> fs render_question(h, form)
  end

  mdef render_question do
    %{type: "text"} = h, form                 -> textinput(form, h)
    %{type: "radio"} = h, form                -> multi(form, h, "radio")
    %{type: "multi"} = h, form                -> multi(form, h, "checkbox")
    %{type: "textbox"} = h, form              -> textbox(form, h)
    %{type: "grid", choicerange: _} = h, form -> grid_select(form, h,
      h.rows, List.to_tuple(h.choicerange))
    %{type: "grid", choices: _} = h, form     -> grid_select(form, h,
      h.rows, h.choices)
  end

  #--------------------------------------------------------------------------------
  # individual question types

  def textinput(form, h) do
    class = case h do
      %{meta: %{class: x} } -> ["class='", x, "'"]
      _ -> ""
    end

    ["<h4>", h.name, 
      ": </h4><input name='#{form}[#{name(form, h)}]' type=text ", class, "><br>"]
  end

  def textbox(form, h) do
    length = case h do
      %{meta: %{length: x} } -> ["<p class='counter' length='", x, "'></p>"]
      _ -> ""
    end

    ["<h4>", h.name, ": </h4>", "<textarea name='#{form}[#{name(form, h)}]'></textarea>", 
      length]
  end

  def multi(form, h, type) do
    name = "#{form}[#{name(form, h)}"

    opts = h.options
    |> Enum.with_index
    |> Enum.map(
      fn {x, i} -> 
        case type do
          "checkbox" -> ["<label><input name='#{name}.#{[?a + i]}]'",
            "value='true' type=checkbox><span>", x, "</span></label>"]
          "radio" -> ["<label><input name='#{name}.#{[?a + i]}]' value='#{[?a + i]}'", 
            "type=radio><span>", x, ": </span></label>"]
        end
      end)

    ["<h4>", h.name, "</h4>", opts]
  end

  #--------------------------------------------------------------------------------
  # grid selection

  def grid_select(form, h, rows, elem_list) do
    if is_tuple(elem_list) do
      {min, max, num} = elem_list
      elems = List.flatten [min, List.duplicate("", String.to_integer(num) - 2), max] 
      labels = Enum.to_list(1..length(elems)) |> Enum.map(&Integer.to_string/1)
    else
      elems = elem_list
      labels = elem_list
    end

    headercells = elems |> Enum.map(fn x -> ["<div class='cell'>", x, "</div>"] end)

    header = ["<h4>", h.name, "</h4><div class='evaluation table'><div class='line answers'>",
      "<div class='cell exception'></div>", headercells, "</div>"]
    body = rows |> Enum.with_index |> Enum.map(fn x -> body_row(h, form, x, labels) end) 
    footer = "</table>"
    [header, body, footer]
  end

  defp body_row(h, form, {desc, i}, elem_list) do 
    selname = "#{form}[#{name(form, h)}.#{[i + ?a]}]"
    sels = elem_list |> Enum.map(&(sel_elem(selname, &1)))
    ["<div class='line'> <div class='cell question'>", desc, "</div>", sels, "</div>"]
  end

  defp sel_elem(name, val) do
    ["<div class='cell answer'> <label> <input type='radio' name='", name, "' value='", val, 
      "'> <span>", val, "</span> </label> </div>"]
  end

  #--------------------------------------------------------------------------------
  # helper functions

  def fs(x), do: ["<fieldset>", x, "</fieldset>"]

  mdef name do
    form, %{meta: %{name: x} } -> x
    form, h                    -> Integer.to_string(h.number)
  end

  #================================================================================ 
  # parsing
  #================================================================================ 

  def parse(file) do
    File.stream!(file)
    |> Stream.filter(&remove_blank_lines/1)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&classify_line_types/1)
    |> concat_blocks
  end

  #--------------------------------------------------------------------------------
  
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
    :section, {_, num, acc}                   -> {:wait, num, [:section | acc]}
    {:header, _} = h, {_, num, acc}           -> {:wait, num, [h | acc]}
    {:question, "para", name}, {_, num, acc}  -> {:wait, num, [{:para, name} | acc]}
    :meta, {_, num, acc}                      -> {:meta, num, acc}
    :choicerange, {_, num, acc}               -> {:choicerange, num, acc}
    :rows, {_, num, acc}                      -> {:rows, num, acc}
    :choices, {_, num, acc}                   -> {:choices, num, acc}

    {:question, "multi", name}, {_, num, acc} -> {:options, num + 1,
      [ %{name: name, number: num, type: "multi"} | acc]}

    {:question, "radio", name}, {_, num, acc} -> {:options, num + 1,
      [ %{name: name, number: num, type: "radio"} | acc]}

    {:question, type, name}, {_, num, acc}    -> {:wait, num + 1,
      [ %{name: name, number: num, type: type} | acc]}

    {:sub, str}, {:meta, num, [h | tl] }      -> { :meta, num,
      [ map_merge(h, :meta, proc_meta( str )) | tl ] }

    {:sub, str}, {elem, num, [h | tl] }       -> { elem, num,
      [ append_in(h, elem, str) | tl ] }
  end

  def proc_meta(str) do
    [k, v] = String.split(str, "=", parts: 2)
    |> Enum.map(&String.strip/1)
    Map.put(%{}, String.to_atom(k), v)
  end

  # takes a list like [1, 2, 3, :section, 4, 5, 6, :section, 8, 9] and
  # creates a set of nested lists: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  mdef sectionify do
    seq                  -> sectionify seq, [[]]
    [:section | tl], acc -> sectionify tl, [[] | acc]
    [h | t], [h2 | t2]   -> sectionify t, [ List.insert_at(h2, 999, h) | t2 ]
    [], acc              -> Enum.reverse acc
  end

  #--------------------------------------------------------------------------------
  # helpers

  def append_in(h, elem, str) do
    Map.update(h, elem, [str], fn x -> List.insert_at(x, 999, str) end)
  end

  def map_merge(h, elem, kv) do
    Map.update(h, elem, kv, fn x -> Map.merge(x, kv) end)
  end

end
