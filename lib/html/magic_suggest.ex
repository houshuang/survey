defmodule Survey.HTML.MagicSuggest do
  def magic_suggest() do
    """ 
    <link href="/css/magicsuggest-min.css" rel="stylesheet">
    <fieldset>
<h4>Tags</h4>
<p>
Please enter a number of tags to describe your teaching areas. Some will be automatically suggested based on your selections above, but you can also add new tags. These tags will help us connect you with other people, resources, and groups relevant to your interests.</p>
    <script src="/js/magicsuggest-min.js"></script>

      <input class="form-control" id="ms-suggest">
    </fieldset>
    <div class='blocks'>
    <script> $(function() { Window.ms = $('#ms-suggest').magicSuggest({name: "tags"}); });</script>
    <div class='block'>
    """
  end


end
