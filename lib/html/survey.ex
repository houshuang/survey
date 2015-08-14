defmodule Survey.HTML.Survey do
  import MultiDef

  #--------------------------------------------------------------------------------
  # main pipeline

  def gen_survey(file, form) do
    parse(file)
    |> do_gen(form)
  end

  def gen_survey_from_struct(struct, form) do
    struct
    |> do_gen(form)
  end

  def do_gen(struct, form) do
    struct
    |> sectionify
    |> Enum.with_index
    |> proc_sections(form)
    |> IO.iodata_to_binary
  end

  #--------------------------------------------------------------------------------
  # sections

  # only print section headers if more than one section
  defp proc_sections([{seq, 0}], form), do: do_section({seq, 0}, form, :single)
  defp proc_sections(seqs, form), do: seqs |> Enum.map(fn x -> do_section(x, form, :many) end)

  defp do_section({seq, i}, form, many) do
    content = Enum.map(seq, fn(x) -> gen_elements(x, form) end)
    display = if i == 0, do: "", else: "display: none"
    sectionheader = case many do
      :single -> ""
      :many   -> if i > 0 do
        "<h1>Section #{i + 1}</h1>"
      else
        ""
      end
    end

    ["<div class='block' style='#{display}'>", sectionheader, content,
      "<hr></div>"]
  end

  #--------------------------------------------------------------------------------
  # elements

  mdefp gen_elements do
    {:header, txt}, _   -> ["<h3>", txt, "</h3>"]
    {:para, txt}, _     -> ["<p>", txt, "</p>"]
    {:function, txt}, _ -> elem(Code.eval_string(txt), 0)
    h, form             -> fs render_question(h, form)
  end

  mdefp render_question do
    %{type: "text"} = h, form    -> textinput(form, h)
    %{type: "radio"} = h, form   -> multi(form, h, "radio")
    %{type: "multi"} = h, form   -> multi(form, h, "checkbox")
    %{type: "textbox"} = h, form -> textbox(form, h)
    %{type: "grid"} = h, form    -> grid_select(form, h)
  end

  #--------------------------------------------------------------------------------
  # individual question types

  defp textinput(form, h) do
    desc = desc(h)
    class = case h do
      %{meta: %{class: x} } -> ["class='", x, "'"]
      _ -> ""
    end

    ["<h4>", numstr(h), h.name,
      "</h4>", desc, "<input name='#{form}[#{name(h)}]' type=text ", class, "><br>"]
  end

  defp textbox(form, h) do
    desc = desc(h)
    length = case h do
      %{meta: %{length: x} } -> ["<p class='counter' length='", x, "'></p>"]
      %{meta: %{minwords: x} } -> ["<p class='counter' min='", x, "'></p>"]
      _ -> ""
    end

    ["<h4>", numstr(h), h.name, "</h4>", desc, "<textarea name='#{form}[#{name(h)}]'></textarea>",
      length]
  end

  defp multi(form, h, type) do
    desc = desc(h)

    opts = h.options
    |> Enum.with_index
    |> Enum.map(
      fn {x, i} ->
        case type do
          "checkbox" -> ["<label><input name='#{form}[#{name(h)}|#{[?a + i]}]'",
            "value='true' type=checkbox><span>", x, "</span></label>"]
          "radio" -> ["<label><input name='#{form}[#{name(h)}]' value='#{[?a + i]}'",
            "type=radio><span>", x, "</span></label>"]
        end
      end)

    ["<h4>", numstr(h), h.name, "</h4>", desc, opts]
  end

  #--------------------------------------------------------------------------------
  # grid selection

  defp grid_select(form, h) do
    if length(h.choicerange) == 3 && string_is_integer(Enum.at(h.choicerange, 2)) do
      [min, max, num] = h.choicerange
      elems = List.flatten [min, List.duplicate("", String.to_integer(num) - 2), max]
      labels = Enum.to_list(1..length(elems)) |> Enum.map(&Integer.to_string/1)
    else
      elems = labels = h.choicerange
    end

    headercells = elems
    |> Enum.with_index
    |> Enum.map(fn {x, i} -> ["<div class='cell cellgradient#{i}'>", x, "</div>"] end)

    header = ["<h4>", numstr(h), h.name,
      "</h4><div class='evaluation table'><div class='line answers'>",
      "<div class='cell exception'></div>", headercells, "</div>"]
    body = h.rows |> Enum.with_index |> Enum.map(fn x -> body_row(h, form, x, labels) end)
    footer = "</table>"
    [header, body, footer]
  end

  defp body_row(h, form, {desc, i}, elem_list) do
    selname = "#{form}[##{name(h)}.#{[i + ?a]}]"
    sels = elem_list |> Enum.map(&(sel_elem(selname, &1)))
    ["<div class='line'> <div class='cell question'>", desc, "</div>", sels, "</div>"]
  end

  defp sel_elem(name, val) do
    ["<div class='cell answer'> <label> <input type='radio' name='", name, "' value='", val,
      "'> <span>", val, "</span> </label> </div>"]
  end

  #--------------------------------------------------------------------------------
  # helper functions

  defp fs(x), do: ["<fieldset>", x, "</fieldset>"]

  mdefp name do
    %{meta: %{name: x} } -> x
    h                    -> Integer.to_string(h.number)
  end

  defp numstr(h), do: [Integer.to_string(h.number), ". "]

  mdefp desc do
    %{meta: %{desc: x} } -> ["<p><i>", x, "</i></p>"]
    _                    -> []
  end

  #================================================================================
  # parsing
  #================================================================================

  def parse(file) do
    File.stream!(file)
    |> do_parse
  end

  def string_parse(str) do
    String.split(str, "\n")
    |> do_parse
  end

  def do_parse(input) do
    input
    |> Stream.filter(&remove_blank_lines/1)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&classify_line_types/1)
    |> concat_blocks
  end

  def index_mapping(struct) do
    Enum.reduce(struct, %{}, fn x, acc ->
      if is_map(x) and x[:number] do
        Map.put acc, x.number, x
      else
        acc
      end
    end)
  end

  #--------------------------------------------------------------------------------

  defp remove_blank_lines(x) do
    x = String.strip(x)
    x != "" && !String.starts_with?(x, "!")
  end

  mdefp classify_line_types do
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

  defp concat_blocks(x) do
    Enum.reduce(x, {:wait, 1, []}, &concat_blocks_proc/2)
    |> elem(2)
    |> Enum.reverse
  end

  mdefp concat_blocks_proc do
    :section, {_, num, acc}                      -> {:wait, num, [:section | acc]}
    {:header, _} = h, {_, num, acc}              -> {:wait, num, [h | acc]}
    {:question, "para", name}, {_, num, acc}     -> {:wait, num, [{:para, name} | acc]}
    {:question, "function", name}, {_, num, acc} -> {:wait, num, [{:function, name} | acc]}
    :meta, {_, num, acc}                         -> {:meta, num, acc}
    :choicerange, {_, num, acc}                  -> {:choicerange, num, acc}
    :rows, {_, num, acc}                         -> {:rows, num, acc}
    :choices, {_, num, acc}                      -> {:choices, num, acc}

    {:question, "multi", name}, {_, num, acc}    -> {:options, num + 1,
      [ %{name: name, number: num, type: "multi"} | acc]}

    {:question, "radio", name}, {_, num, acc}    -> {:options, num + 1,
      [ %{name: name, number: num, type: "radio"} | acc]}

    {:question, type, name}, {_, num, acc}       -> {:wait, num + 1,
      [ %{name: name, number: num, type: type} | acc]}

    {:sub, str}, {:meta, num, [h | tl] }         -> { :meta, num,
      [ map_merge(h, :meta, proc_meta( str )) | tl ] }

    {:sub, str}, {elem, num, [h | tl] }          -> { elem, num,
      [ append_in(h, elem, str) | tl ] }
  end

  defp proc_meta(str) do
    [k, v] = String.split(str, "=", parts: 2)
    |> Enum.map(&String.strip/1)
    Map.put(%{}, String.to_atom(k), v)
  end

  # takes a list like [1, 2, 3, :section, 4, 5, 6, :section, 8, 9] and
  # creates a set of nested lists: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  mdefp sectionify do
    seq                  -> sectionify seq, [[]]
    [:section | tl], acc -> sectionify tl, [[] | acc]
    [h | t], [h2 | t2]   -> sectionify t, [ List.insert_at(h2, 999, h) | t2 ]
    [], acc              -> Enum.reverse acc
  end

  #--------------------------------------------------------------------------------
  # helpers

  defp append_in(h, elem, str) do
    Map.update(h, elem, [str], fn x -> List.insert_at(x, 999, str) end)
  end

  defp map_merge(h, elem, kv) do
    Map.update(h, elem, kv, fn x -> Map.merge(x, kv) end)
  end

  defp string_is_integer(str) do
    case Integer.parse(str) do
      {_, ""} -> true
      _ -> false
    end
  end

end
