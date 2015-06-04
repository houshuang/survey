defmodule Survey.Helpers do

  def gettags do
    {:ok, content} = File.read("data/tags.json")
    Phoenix.HTML.raw content
  end
end
