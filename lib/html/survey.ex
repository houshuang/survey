defmodule Survey.HTML.Survey do
  import MultiDef

  def parse(file) do
    File.stream!(file)
    |> Stream.filter(fn x -> String.strip(x) != "" end)
    |> Stream.map(&String.rstrip/1)
    |> Stream.map(&line_types/1)
    |> Enum.reduce({:wait, []}, &concat_blocks/2)
    |> elem(1)
    |> Enum.reverse
    |> IO.inspect
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

  # def conc_tr(x,y) do 
  #   IO.inspect(y)
  #   IO.inspect(x)
  #   IO.puts("------------------------------")
  #   res = concat_blocks(x,y)
  #   IO.inspect(res)
  #   IO.puts("==============================\n")
  #   res
  # end

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
