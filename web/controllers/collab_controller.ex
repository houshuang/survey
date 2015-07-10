defmodule Survey.CollabController do
  use Survey.Web, :controller
  alias Survey.DesignGroup
  alias Survey.Etherpad
  require Logger

  def index(conn, _) do
    user = conn.assigns.user
    if !is_nil(get_session(conn, :email)) do
      Logger.info("#{user.id} arrived through email link")
    end

    group = DesignGroup.get_by_user(user.id)
    if !group.design_group_id do
      html conn, "You are not part of a design group"
    else
      members = DesignGroup.get_members(group.design_group_id)
      etherpad = Etherpad.ensure_etherpad(group.design_group_id)

      others = members
      |> Enum.filter(fn [x, _] -> x != user.id end)

      Mail.send_notification(conn, group.design_group_id, user.nick, 
        group.design_group.title, others)
      conn
      |> put_layout(false)
      |> render "index.html", user: user, 
        group: group.design_group, 
        etherpad: etherpad,
        members: members
    end
  end

  def leave(conn, _) do
    Logger.info("User left design group")
    %{ conn.assigns.user | design_group_id: nil } |> Repo.update!
    ParamSession.redirect(conn, "/design_groups/select")
  end
end

