defmodule Mail.Receive do
  require Logger
  @hashid Hashids.new(salt: Application.get_env(:mailer, :hashid_salt))

  def receive_message(from, to, data) do
    try do
      email = data
      |> Mailman.Email.parse!

      case extract_user_group(to) do
        {:ok, user, group} ->
          forward(user, group, email)
        {:error, _} ->
          Logger.info("Email: Received email, black hole")
          nil
      end
    catch
      e -> Logger.warn(inspect(e))
    end
  end

  def forward(user, group, email) do
    Logger.info("Email: Received valid group mail")

    content = if email.html == "", do: email.text, else: email.html

    Mail.send_group_email(user.design_group_id,
      user.id, user.nick, email.subject, content, false)
  end

  def extract_user_group([to]) do
    if String.contains?(to, "-design_group@mooc.encorelab.org") do
      hash = String.replace(to, "-design_group@mooc.encorelab.org", "")
      try do
        [user_id, group_id] = Hashids.decode!(@hashid, hash)

        group = Survey.DesignGroup.get(group_id)
        if is_nil(group), raise: "MailReceive: No such design group"

        user = Survey.User.get(user_id)
        if is_nil(user), raise: "MailReceive: No such user"
        if user.design_group_id != group.id, raise: "User not member of group"

        {:ok, user, group}

      rescue e ->
        Logger.warn(inspect(e))
        {:error, :failed}
      end
    else
      {:error, :not_design_group}
    end
  end
end
