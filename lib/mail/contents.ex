defmodule Mail.Contents do
  alias Survey.User
  alias Survey.SIG
  alias Survey.DesignGroup
  alias Survey.Resource
  alias Survey.Commentstream
  import Ecto.Query
  require Ecto.Query

  def add(lst, item), do: List.insert_at(lst, 0, item)

  def generate(data) do
    url = fn x -> Mail.gen_url(data.user.id, x) end

    text = "<p>This email will give you a short update on the MOOC. We have been learning a lot about how to organize this kind of course, and how to support groups of teachers working on curriculum design. Here is a personalized update on your participation so far: <p>"
    
    reflection = if data.reflection_submit do 
      "You have not yet submitted your weekly reflection
      for week 1, <a href='#{url.("/reflection")}'>go here to do so</a>."
    else
      "You have submitted your reflection for week 1."
    end

    design_group = if data.design_group do 
      "You have joined the design team
      #{data.design_group.title}. We hope you were able to add some ideas to the
      Etherpad, and update your Design description for the wider community to
      review.  We are working on the best ways to support your online
      collaboration and will be introducing a new Wiki tool, and some more
      collaboration features." 
    else
      "You have not joined any design team. Perhaps when you are reviewing the
      designs from your SIG in this week's activities, you will find a group
      that you would like to join.  If you don't have time for design activity
      this summer, we hope you will pay attention to the designs that are
      emerging over the next few weeks, and give your best advice."
    end
    {"Hi, and welcome to week 2, #{data.user.nick}! ", text <> reflection <> "<p>Last week you completed #{data.activity_count} of
    the 3 inquiry activities. <p>#{design_group}<p>Thank you very much
    for your participation, and we look forward to seeing you online.  <p> Jim,
    Rosemary and the MOOC design team<p>
      <p><i>Please don't respond to this email, replies will not be received. Add a message in the Tech issues thread in the forum, if you have any concerns. (Note that there was a bug in the email code, which led to some of you being unable to unsubscribe. It should be fixed, so please try again).</i></p>

  <a href='#{url.("/email/unsubscribe/collab}")}'>Unsubscribe from design group notifications</a> | <a href='#{url.("/email/unsubscribe/all")}'>Unsubscribe from all personalized emails</a>"}
  end

  def get_data(user) do
    if !user, do: raise "No user"
    id = user.id
    activity_count = (from f in Survey.UserGrade,
    where: f.user_id == ^id,
    where: f.component in ["design_critique", "add_resource", "review_resource"],
    select: count(f.id)) |> Survey.Repo.one
    %{
      user: user,
      reflection_submit: Survey.Reflection.get(id, 1),
      activity_count: activity_count,
      design_group: Survey.DesignGroup.get_by_user(id).design_group
    }
  end
end

