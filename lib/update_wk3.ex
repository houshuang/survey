defmodule Survey.Update.Wk3 do
  alias Survey.Encore
  @above "<h1>5. What is the activity structure of the lesson?</h1>"
  @new "<p><span>4c. Use of Handheld or Mobile Computers</span></p><p><span style=\"color: rgb(0,0,0);\"><em>
  Will students or teacher use smart phones, tablets, or any other mobile devices?  If you haven't yet considered this, perhaps there could there be a supplemental activity that students complete outside of class.</em></span></p><p><span style=\"color: rgb(128,0,0);\"> - - - add your response here (delete this line of text) - - -</span></p>"

  def change_text(txt) do
    if !String.contains?(txt, @new) do
      if String.contains?(txt, @above) do
        [txt1, txt2] = String.split(txt, @above)
        txt1 <> @new <> @above <> txt2
      else
        txt <> @new
      end
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
      #   Mail.send_group_email(id, 0, "INQ101x update", "Design Track week 3 is open", @content)
      # end

end
