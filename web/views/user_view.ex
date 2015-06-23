defmodule Survey.UserView do
  use Survey.Web, :view

  @registration raw Survey.HTML.Survey.gen_survey("data/registration.txt", :f)

  @tags Survey.Helpers.gettags
  @choices Survey.Helpers.getchoices
  
  def tags, do: @tags
  def sigs, do: Survey.Repo.all(Survey.SIG)
  def choices, do: @choices
  def registration, do: raw Survey.HTML.Survey.gen_survey("data/registration.txt", :f)
end
