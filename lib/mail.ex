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
  
  def send_wk2(conn) do
    template = %Mailman.Email{
      subject: "Welcome to Week 2",
      from: "noreply@mooc.encorelab.org",
    }
    # Enum.map(Survey.Repo.all(Survey.User), fn x -> 
    Enum.map([Survey.Repo.get(Survey.User, 647)], fn x -> 
      Task.Supervisor.start_child(:email_sup, fn ->
        send_wk2_individ(conn, template, x)
      end)
    end)
  end

  def send_wk2_individ(conn, template, user) do
    {subj, html} = Mail.Contents.get_data(user)
    |> Mail.Contents.generate(conn)
    html = Templates.common(subj, html)

    %{ template | 
      to: [user.edx_email],
      html: html ,
      text: html}
    |> Survey.Mailer.deliver
    Logger.info("Sent email")
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

  def gen_url(conn, user, url) do
    conn
    |> Conn.clear_session
    |> Conn.put_session(:repo_userid, user.id)
    |> Conn.put_session(:lti_userid, user.hash)
    |> Conn.put_session(:email, true)
    ParamSession.gen_url(@basename <> url)
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

