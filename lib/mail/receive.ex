defmodule Mail.Receive do
  require Logger
  @hashid Hashids.new(salt: Application.get_env(:mailer, :hashid_salt))

  def receive_message(from, to, data) do
    email = data
    |> Mailman.Email.parse!

    case extract_group_id(to) do
      {:error, _} -> 
      Logger.info("Email: Received email, black hole")
      nil
      {:ok, [id, group_id]} when is_integer(group_id) -> 
        try_forward(id, group_id, email)
    end
  end

  def try_forward(id, group_id, email) do
    group = Survey.DesignGroup.get(group_id)
    if !group do
      Logger.info("Email: No such design group")
      %Mailman.Email{from: "mailer@mooc.encorelab.org", 
        to: email.from, 
        subject: "No such design group", 
        text: "You just sent an email to a design group that does not exist"}
      |> Mail.schedule_send
    else
      user = Survey.User.get(id)
      if !user do
      Logger.info("Email: User not member of design group")
        %Mailman.Email{from: "mailer@mooc.encorelab.org", 
          to: email.from, 
          subject: "Not member of design group", 
          text: "No member of this design group has your email. Make sure you use the email that you 
          registered with EdX to respond to messages."}
        |> Mail.schedule_send
      else
        Logger.info("Email: Received valid group mail")
        content = if email.html == "", do: email.text, else: email.html
        Mail.send_group_email(user.design_group_id, user.id, user.nick, email.subject, 
          content, false)
      end
    end
  end

  def extract_group_id([to]) do
    if String.contains?(to, "-design_group@mooc.encorelab.org") do
      hash = String.replace(to, "-design_group@mooc.encorelab.org", "")
      Hashids.decode(@hashid, hash)
    else
      {:error, :not_design_group}
    end
  end

  def group_address(id) do
    hash = Hashids.encode(@hashid, id)
  end
end
