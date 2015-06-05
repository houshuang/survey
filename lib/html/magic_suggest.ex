defmodule Survey.HTML.MagicSuggest do
  def magic_suggest() do
    """ 
    <fieldset>
<h4>Tags</h4>
<p>
Please enter a number of tags to describe your teaching areas. Some will be automatically suggested based on your selections above, but you can also add new tags. These tags will help us connect you with other people, resources, and groups relevant to your interests.</p>
    <script src="/js/tag-it.min.js"></script>

      <input class="form-control" id="ms-suggest">
    </fieldset>

    """
  end


end
