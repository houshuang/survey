defmodule Survey.HTML.MagicSuggest do
  def magic_suggest(name, data, opts \\ %{}) do
    opts = opts 
            |> Map.merge(%{data: data})
            |> Map.merge(%{name: name})
            |> Poison.encode!(opts)
    """ 
    <link href="/css/magicsuggest-min.css" rel="stylesheet">

    <script src="/js/magicsuggest-min.js"></script>

    <div class="form-group">
      <label>Teaching interests</label>
      <input class="form-control" id="ms-scrabble">
    </div>
    <script> $(function() { $('#ms-scrabble').magicSuggest(#{opts}); });</script>
    """
  end


end
