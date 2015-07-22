defmodule Survey.Update.Wk3 do
  alias Survey.Encore
  @above "<h1>5. What is the activity structure of the lesson?</h1>"
  @new "<p><span>4b. Peer Collaboration</span></p><p><span style=\"color: rgb(0,0,0);\"><em>
How will your lesson allow for students to learn from their peers?  How will you allow their inquiry products to contribute to peers or the wider classroom community?</em></span></p><p><span style=\"color: rgb(128,0,0);\"> - - - add your response here (delete this line of text) - - -</span></p>"
  @content "Welcome to a new week of the design strand. We have added a new welcome page, Etherpad prompts, and wiki prompt (4.2). You can also see any comments your SIG members have left on your design wiki page. (The wiki page shown to SIG members is updated once an hour, and the comments are updated live, so you might get more feedback as you keep improving the page.<P><BR>
  We have mentioned the new 'mailing list' functionality in a previous e-mail. If you click on the e-mail button on the collaborative workbench (by the chat window), you can write an e-mail to all your group members. If you reply to that e-mail, the response also goes to all group members. <p><br><b>This e-mail is an example - if you respond, the answer will go to all your group members. Perhaps you want to discuss how to proceed, when to meet online, etc?</b><p><br> Note that you can always unsubscribe from e-mails with the links at the bottom.<p><br>
  Have a great week, <p><br>
  <i>The INQ101x MOOC team</i>"

  def change_text(txt) do
    if String.contains?(txt, @above) do
      [txt1, txt2] = String.split(txt, @above)
      txt1 <> @new <> @above <> txt2
    else
      txt <> @new
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

  def mail_all do
    Survey.DesignGroup.get_all_active
    |> Enum.map(fn x ->
      Survey.Job.add({Survey.Update.Wk3, :mail, [x]}) end)
  end

  def mail(id) do
    Mail.send_group_email(id, 0, "INQ101x update", "Design Track week 3 is open", @content)
  end

end
