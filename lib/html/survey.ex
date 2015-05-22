defmodule Survey.HTML.Survey do
  import MultiDef
  import Survey.HTML.Helpers
  import Phoenix.HTML
  import Phoenix.HTML.Form

  def gen_survey(file, form) do
    parse(file)
    |> Enum.map(fn(x) -> gen_elements(x, form) end)
    |> IO.iodata_to_binary
    |> raw
  end

  mdef unsafe_concat do
    {:safe, x} -> x
    x when is_list(x) -> x
    x when is_binary(x) -> x
  end

  mdef gen_elements do
    {:header, txt}, form -> ["<h3>", txt, "</h3>"]
    %{type: "text"} = h, form -> ["<label>", h.name, ": </label>", unsafe(text_input(form, String.to_atom(h.name)))]
    %{type: "radio"} = h, form -> radio(h, form)
    %{type: "multi"} = h, form -> multi(h, form)
    %{type: "textbox"} = h, form -> ["<label>", h.name, ": </label>", unsafe(textarea(form, h.name))]
    %{type: "grid", choicerange: _} = h, form -> unsafe(grid_select(h.name, h.rows, h.choicerange))
    %{type: "grid", choices: _} = h, form -> unsafe(grid_select(h.name, h.rows, h.choices))
  end

  def multi(h, form) do
    opts = h.options
    |> Enum.map(
      fn x -> [unsafe(checkbox(form, String.to_atom("#{h.name}.#{x}"))), "<label>", x, ": </label><br>", ] end)
    ["<h3>", h.name, "</h3>", opts]
  end

  def radio(h, form) do
    opts = h.options
    |> Enum.map(fn x -> 
    
      [unsafe(radio_button(form, String.to_atom("#{h.name}.#{x}"), "false")), "<label>", x, ": </label><br>", ] end )
    ["<h3>", h.name, "</h3>", opts]
  end
  
  
  mdef unsafe do
    {:safe, x} -> x
    x -> x
  end

  def parse(file) do
    File.stream!(file)
    |> Stream.filter(fn x -> String.strip(x) != "" end)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&line_types/1)
    |> Enum.reduce({:wait, []}, &concat_blocks/2)
    |> elem(1)
    |> Enum.reverse
  end
  
  mdef line_types do
    "#"<>rest -> {:header, rest}
    " "<>rest -> {:sub, rest}
    "\t"<>rest -> {:sub, rest}
    "choices" -> :choices
    "choicerange" -> :choicerange
    "rows" -> :rows
    rest -> [type, q] = String.split(rest, ",", parts: 2); {:question, type, String.strip(q)}
  end

  mdef concat_blocks do
    :choicerange, {_, acc} -> {:choicerange, acc}
    :rows, {_, acc} -> {:rows, acc } 
    :choices, {_, acc} -> {:choices, acc } 
    {:question, "multi", name}, {_, acc} -> {:options, [%{name: name, type: "multi"} | acc]}
    {:question, "radio", name}, {_, acc} -> {:options, [%{name: name, type: "radio"} | acc]}

    {:question, type, name}, {_, acc} -> {:wait, [%{name: name, type: type} | acc]}
    {:header, _} = h, {_, acc} -> {:wait, [h | acc]}

    {:sub, str}, {elem, [h | tl] } -> { elem, [ append_in(h, elem, str) | tl ] }
  end

  def append_in(h, elem, str), do: Map.update(h, elem, [str], fn x -> List.insert_at(x, 999, str) end)
end
