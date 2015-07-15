defmodule Mail do
  alias Mail.Templates
  require Logger
  import Ecto.Query
  require Ecto.Query
  alias Plug.Conn

  @basename Application.get_env(:mailer, :basename)
  @hashid Hashids.new(salt: Application.get_env(:mailer, :hashid_salt))
  @wk2 File.read!("data/templates/wk2.txt")

  def send_design do
    (from f in Survey.User,
    where: not is_nil(f.design_group_id))
    |> Enum.map(&send_design1/1)
  end

  def send_design1(user) do
    if !Survey.User.is_unsubscribed?(user.id, "collab") do
      html = Templates.collab_wk2(user.id, @basename)
      email = %Mailman.Email{from: "noreply@mooc.encorelab.org", to: [user.edx_email],
        subject: "Design Strand week 2 is open!", html: html}
      Survey.Job.add({Survey.Mailer, :deliver, [email]})
    end
  end

  def send_notification(room, entered, design, userids) when is_list(userids) do
    if Application.get_env(:mailer, :disabled) do
      Logger.warn("Emailing disabled")
    else
      Task.Supervisor.start_child(:email_sup, fn ->
        Enum.each(userids, fn [id, nick] -> 
          if !Survey.User.is_unsubscribed?(id, "collab") &&
            Survey.ChatPresence.not_online?(room, id) do
              generate_notification(entered, design, [id, nick])
              |> Survey.Mailer.deliver

              Logger.info("Sent email to #{id}")
          end
        end)
      end)
    end
  end

  def generate_notification(entered, design, [id, nick]) do
    email = (from f in Survey.User,
    where: f.id == ^id,
    select: f.edx_email) |> Survey.Repo.one
    
    text = Templates.collab_notification_text(nick, entered, design, 
      id, @basename)
    html = Templates.collab_notification_html(nick, entered, design, 
      id, @basename)

    %Mailman.Email{
      subject: "#{entered} entered the collaborative workbench",
      from: "noreply@mooc.encorelab.org",
      to: [email],
      text: text,
      html: html }
  end
  
  def send_wk2 do
    template = %Mailman.Email{
      subject: "Welcome to Week 2",
      from: "noreply@mooc.encorelab.org",
    }

    # Enum.map((from f in Survey.User, where: f.id == 647) |> Survey.Repo.all, fn x -> 

    Enum.map((from Survey.User) |> Survey.Repo.all, fn x -> 
      Task.Supervisor.start_child(:email_sup, fn ->
        :timer.sleep(:random.uniform(100000))
        send_wk2_individ(template, x)
      end)
    end)
  end

  def send_wk2_individ(template, user) do
    {subj, text} = Mail.Contents.get_data(user)
    |> Mail.Contents.generate
    html = Templates.common(subj, text)

    %{ template | 
      to: [user.edx_email],
      html: html,
      text: text}
    |> Survey.Mailer.deliver

    Logger.info("Sending wk2 mail to #{user.id}")
  end

  def gen_url(id, url) do
    term = %{url: url, userid: id}
    id = Survey.Cache.store(term)
    hash = Hashids.encode(@hashid, id)
    @basename <> "/email/" <> hash
  end
end

