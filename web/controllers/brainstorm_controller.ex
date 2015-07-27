defmodule Survey.BrainstormController do
  use Survey.Web, :controller

  def index(conn, _) do
    user = conn.assigns.user
    conn
    |> put_layout(false)
    |> render "index.html", user_id: user.id, room: user.sig_id
  end
end
