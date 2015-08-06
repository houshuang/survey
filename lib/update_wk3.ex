defmodule Survey.Update.Wk3 do
  alias Survey.Encore
  @above "<h1>5. What is the activity structure of the lesson?</h1>"
  @new "<div><span style=\"color: rgb(51,51,51);\">4d. Supporting Equity and Diversity</span></div><p><em>How will your lesson embrace diversity in the classroom (as a positive feature, meaning that your lesson is better off for having diversity, and its not a problem to overcome!) &nbsp;How will it help ensure equity for the various students in the classroom?</em></p><p><span style=\"color: rgb(128,0,0);\">- - - add your response here (delete this line of text)&nbsp;- - -</span></p>"
  @bottom "<h1>6. Assessment notes.</h1><p><em>How will student progress be assessed?&nbsp; Try to include the technology-enhanced parts of your lesson into the assessment plan. For example, if students are making drawings or concept maps - how will those artifacts be used for purposes of assessment (formative or summative).&nbsp;</em></p><div><em><span style=\"color: rgb(128,0,0);\"><br /></span></em></div><div><span style=\"color: rgb(128,0,0);\">- - - add your response here (delete this line of text) - - -</span>&nbsp;</div><h1>7. Enactment notes.</h1><p><em>How will the teacher ensure that this lesson goes as planned?&nbsp; What kinds of hints would you give to any teacher who was going to run this lesson? How should the teacher use her/his time in the classroom most effectively, while the kids are using the technology (hint: its not just to make sure the computers are all working and kids are staying on-task!) What kinds of interactions should the pursue with students?</em><span style=\"color: rgb(128,0,0);\">&nbsp;</span></p><div><span style=\"color: rgb(128,0,0);\">- - - add your response here (delete this line of text) - - -</span></div><h2>7a. Ethics or enactment concerns</h2><p><em>What are some of the possible ethics concerns, for teachers?&nbsp; What kinds of things could go wrong, and how could you pre-empt those with advance organization and communication?</em></p><div><span style=\"color: rgb(128,0,0);\">- - - add your response here (delete this line of text) - - -</span></div><p><span style=\"color: rgb(128,0,0);\"><br /></span></p>"

  def change_text(txt) do
    if !String.contains?(txt, @new) do
      if String.contains?(txt, @above) do
        [txt1, txt2] = String.split(txt, @above)
        txt1 <> @new <> @above <> txt2 <> @bottom
      else
        txt <> @new <> @bottom
      end
    else
      txt
    end
  end

  def change_group(id) do
    {:ok, page} = Encore.get_page(id)
    %{ page | "content" => change_text(Map.get(page, "content")) }
                          |> Encore.store_page
  end

  def change_all_groups do
    Survey.DesignGroup.get_all_active
    |> Enum.map(fn x -> Survey.Job.add({Survey.Update.Wk3, :change_group, [x]}) end)
  end

  # def mail_all do
    #   Survey.DesignGroup.get_all_active
  #   |> Enum.map(fn x ->
    #     Survey.Job.add({Survey.Update.Wk3, :mail, [x]}) end)
    # end

    # def mail(id) do
      #   Mail.send_group_email(id, 0, "INQ101x update", "Design Track week 5 is open", @content)
      # end

end
