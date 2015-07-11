defmodule Mail.Templates do
  require EEx
  EEx.function_from_file :def, :common, "data/mailtemplates/common.eex", [:title, :content]
  EEx.function_from_file :def, :collab_notification_html, "data/mailtemplates/collab_notification.html.eex", [:name, :entered_name, :design_name, :cookie, :basename]
  EEx.function_from_file :def, :collab_notification_text, "data/mailtemplates/collab_notification.txt.eex", [:name, :entered_name, :design_name, :cookie, :basename]
  EEx.function_from_file :def, :notification_wk1, "data/mailtemplates/to_design_wk1.html.eex", 
  [:cookie, :basename]
end

defmodule Mail do
  alias Mail.Templates
  require Logger
  import Ecto.Query
  require Ecto.Query
  alias Plug.Conn

  @basename Application.get_env(:mailer, :basename)

  def send_notification(conn, room, entered, design, userids) when is_list(userids) do
    if Application.get_env(:mailer, :disabled) do
      Logger.warn("Emailing disabled")
    else
      Task.Supervisor.start_child(:email_sup, fn ->
        Enum.each(userids, fn [id, nick] -> 
          if !Survey.User.is_unsubscribed?(id, "collab") &&
            Survey.ChatPresence.not_online?(room, id) do
              generate_notification(conn, entered, design, [id, nick])
              |> Survey.Mailer.deliver

              Logger.info("Sent email to #{id}")
          end
        end)
      end)
    end
  end

  def generate_notification(conn, entered, design, [id, nick]) do
    [email, hash] = (from f in Survey.User,
    where: f.id == ^id,
    select: [f.edx_email, f.hash]) |> Survey.Repo.one
    
    cookie = conn
    |> Conn.clear_session
    |> Conn.put_session(:repo_userid, id)
    |> Conn.put_session(:lti_userid, hash)
    |> Conn.put_session(:email, true)
    |> ParamSession.gen_cookie

    text = Templates.collab_notification_text(nick, entered, design, 
      cookie, @basename)
    html = Templates.collab_notification_html(nick, entered, design, 
      cookie, @basename)

    %Mailman.Email{
      subject: "#{entered} entered the collaborative workbench",
      from: "noreply@mooc.encorelab.org",
      to: [email],
      text: text,
      html: html }
  end
  
  def send_wk1(conn) do
    template = %Mailman.Email{
      subject: "Update on design groups",
      from: "noreply@mooc.encorelab.org",
      text: File.read!("data/mailtemplates/to_design_wk1.txt.eex"),
    }
    Enum.map(Survey.DesignGroup.all_involved, fn x -> 
      Task.Supervisor.start_child(:email_sup, fn ->
        send_wk1_individ(conn, template, x)
      end)
    end)
  end

  def send_wk1_individ(conn, template, id) do
    [email, hash] = (from f in Survey.User,
    where: f.id == ^id,
    select: [f.edx_email, f.hash]) |> Survey.Repo.one

    cookie = conn
    |> Conn.clear_session
    |> Conn.put_session(:repo_userid, id)
    |> Conn.put_session(:lti_userid, hash)
    |> Conn.put_session(:email, true)
    |> ParamSession.gen_cookie

    
    %{ template | 
      to: [email],
      html: Templates.notification_wk1(cookie, @basename) }
    |> Survey.Mailer.deliver
    Logger.info("Sent email")
  end


  def gen_url(conn, id, url) do
    tmp_conn = Plug.Conn.put_session(conn, :edx_userid, id)
    ParamSession.gen_url(tmp_conn, @basename <> url)
  end

  def user_mail(id) do
    subject = "Welcome to Week 2!"
    {text, email} = Mail.Contents.generate(id)
    %Mailman.Email{
      subject: subject,
      from: "noreply@mooc.encorelab.org",
      to: [ email ],
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

  def add(lst, item), do: List.insert_at(lst, 0, item)

  def generate(id) do
    user = User.get(id)
    if !user, do: raise "No user"
    resource_submit = Resource.user_submitted_no(id)
    design_group_submit = DesignGroup.submitted_count(id)
    comments = length(Commentstream.get_by_userid(id))
    text = "Hi, and welcome to week 2! We wanted to give you a small update on what's been
    happening in the course. "
    activity = []
    if comments > 0, do: activity = add(activity, "submitting #{comments} comments on archived lesson plans")
    if (x = resource_submit) > 0, do: activity = add(activity, "submitting #{x} resources")
    if user.resources_seen && length(user.resources_seen) > 0 do
      activity = add activity, "reviewing #{x} resources"
    end
    if (x = design_group_submit) > 0, do: activity = add(activity, "submitting #{x} design group ideas")
    if !Enum.empty?(activity) do
      text = text <> "Thank you for all your activity - #{Enum.join(activity, ", ")}! "
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
    {text, user.edx_email}
    
  end
end
