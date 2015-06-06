defmodule Survey.Helpers do

  # reading files for caching in views
  def gettags do
    {:ok, content} = File.read("data/tags.json")
    Phoenix.HTML.raw content
  end

  def getchoices do
    {:ok, content} = File.read("data/registration_choices.json")
    Phoenix.HTML.raw content
  end

end
