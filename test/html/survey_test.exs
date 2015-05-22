defmodule Survey.HTML.SurveyTest do
  use ExUnit.Case, async: true
  import Survey.HTML.Survey

  test "headline" do 
     assert [{:headline, "Teacher Background"} | _] = parse("data/survey.txt") 
  end
end
