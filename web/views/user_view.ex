defmodule Survey.UserView do
  use Survey.Web, :view

  @registration raw Survey.HTML.Survey.gen_survey("data/registration.txt", :f)

  @tags Survey.Helpers.gettags

  def tags, do: @tags
  def registration, do: raw Survey.HTML.Survey.gen_survey("data/registration.txt", :f)
end
