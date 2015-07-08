defmodule Mail.Templates do
  require EEx
  EEx.function_from_file :def, :common, "data/mailtemplates/common.eex", [:title, :content]
end

defmodule Mail do
  alias Mail.Templates

  def user_mail(id) do
    subject = "Welcome to Week 2!"
    text = Mail.Contents.generate(id)
    %Mailman.Email{
      subject: subject,
      from: "shaklev@gmail.com",
      to: [ "shaklev@gmail.com" ],
      text: text,
      html: Templates.common(subject, text)
    }
  end

  def send_users(users) when is_list(users) do
    users
    |> Stream.map(fn id -> Task.async(fn -> user_mail(id) end) end)
    |> Stream.map(fn x -> Task.await x, 10000000 end)
    |> Stream.map(&Survey.Mailer.deliver/1)
    |> Enum.map(fn x -> Task.await x, 10000000 end)
    |> Enum.reduce({0,0}, &count_success/2)
    |> (fn {success, failure} -> "#{success} sent successfully, #{failure} failures" end).()
  end

  def count_success({:ok, _}, {succ, fail}), do: {succ + 1, fail}
  def count_success({_, _}, {succ, fail}), do: {succ, fail + 1}
end

defmodule Mail.Contents do
  alias Survey.User
  alias Survey.SIG
  alias Survey.DesignGroup
  alias Survey.Resource
  alias Survey.Commentstream

  def generate(id) do
    user = User.get(id)
    if !user, do: raise "No user"
    resource_submit = Resource.user_submitted_no(id)
    design_group_submit = DesignGroup.submitted_count(id)
    comments = length(Commentstream.get_by_userid(id))
    text = "Hi, and welcome to week 2! We wanted to give you a small update on what's been
    happening in the course. "
    activity = []
    if comments > 0, do: ["submitting #{comments} comments on archived lesson plans"|activity]
    if x = design_group_submit, do: ["submitting #{x} resources"|activity]
    if y = user.resources_seen && !Enum.empty?(user.resources_seen), do: ["reviewing #{x} resources"|activity]
    if x = design_group_submit, do: ["submitting #{x} design group ideas"|activity]
    if !Enum.empty?(activity) do
      text = text <> "Thank you for all your activity - #{Enum.join(activity, ", ")}!"
    end

    design = if user.design_group_id do
      group = DesignGroup.get(user.design_group_id)
      membercount = length(DesignGroup.get_members(group.id))
      "It's great that you joined the design group #{group.title}. 
      The group already has #{membercount} members, and we look forward to see what
      you come up with!"
    else
      groups_in_sig = length(DesignGroup.get_by_sig(user.sig_id || 0))
      signame = SIG.name(user.sig_id || 0)
      "You haven't joined a design group yet - perhaps you can have a look at the 
      #{groups_in_sig} available design ideas in your SIG #{signame}."
    end
    text = text <> design
    
  end
end
