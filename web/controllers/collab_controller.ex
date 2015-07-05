defmodule Survey.CollabController do
  use Survey.Web, :controller
  alias Survey.DesignGroup
  alias Survey.Etherpad

  def index(conn, _) do
    user = conn.assigns.user
    group = DesignGroup.get_by_user(user.id)
    if !group.design_group_id do
      html conn, "You are not part of a design group"
    else
      members = DesignGroup.get_members(group.design_group)
      etherpad = Etherpad.ensure_etherpad(group.design_group_id)

      conn
      |> put_layout(false)
      |> render "index.html", user: user, 
        group: group.design_group, 
        etherpad: etherpad,
        members: members
    end
  end
end

