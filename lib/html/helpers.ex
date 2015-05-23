defmodule Survey.HTML.Helpers do
  require Logger
  import Phoenix.HTML

  def multi(form, name, options) do
    "Multi: #{name}"
  end
  
  def magic_suggest(name, data, opts \\ %{}) do
    opts = opts 
            |> Map.merge(%{data: data})
            |> Map.merge(%{name: name})
            |> Poison.encode!(opts)
    raw """ 
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" rel="stylesheet">
    <link href="/css/magicsuggest-min.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
    <script src="/js/magicsuggest-min.js"></script>

    <div class="form-group">
      <label>Teaching interests</label>
      <input class="form-control" id="ms-scrabble">
    </div>
    <script> $(function() { $('#ms-scrabble').magicSuggest(#{opts}); });</script>
    """
  end

  def grid_select(name, rows, cols) when is_list(rows) do
    rows = rows |> Enum.map(fn x -> {x, x} end) |> Enum.into(%{})
    grid_select(name, rows, cols)
  end

  def grid_select(name, rows, {min, max, num}) when is_map(rows) do
    elem_list = 1..String.to_integer(num) 
      |> Enum.to_list
      |> Enum.map(&Integer.to_string/1)

    header = elem_list |> Enum.map(&tdwrap/1)

    header = ["<table>", trwrap(["<td></td>", tdwrap(min), header, tdwrap(max)])]
    body = rows |> Enum.map(fn x -> body_row(name, x, elem_list) end)
    footer = "</table>"
    raw IO.iodata_to_binary([header, body, footer])
  end

  def grid_select(name, rows, elem_list) when is_list(elem_list) do
    header = elem_list |> Enum.map(&tdwrap/1)

    header = ["<table>", trwrap(["<td></td><td></td>", header])]
    body = rows |> Enum.map(fn x -> body_row(name, x, elem_list) end)
    footer = "</table>"
    raw IO.iodata_to_binary([header, body, footer])
  end

  defp body_row(name, {key, desc}, elem_list) do 
    selname = [name, ".", key]
    sels = elem_list |> Enum.map(&(sel_elem(selname, &1)))
    trwrap([tdwrap(desc), tdwrap(""), sels])
  end

  defp sel_elem(name, val), do: tdwrap(["<input type='radio' name='", name, "' value='", val, "' />"])

  defp tdwrap(x), do: ["<td>", x, "</td>"]
  defp trwrap(x), do: ["<tr>", x, "</tr>"]

end
