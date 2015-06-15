defmodule Survey.AdminView do
  use Survey.Web, :view
  import ExPrintf
  def format_percentage(perc) do
    sprintf("%.1f", [perc * 100])
  end

end

