defmodule Survey.HTML.MagicSuggest do
import Phoenix.HTML
  def tag_input(name, data, opts \\ %{}) do
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
end
