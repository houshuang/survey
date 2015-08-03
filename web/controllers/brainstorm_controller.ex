defmodule Survey.BrainstormController do
  use Survey.Web, :controller
  @wk1 File.read!("data/templates/brainstorm/1.txt") |> String.strip
  @wk2 File.read!("data/templates/brainstorm/2.txt") |> String.strip


  def index(conn, _) do
    user = conn.assigns.user
    conn
    |> put_layout(false)
    |> render "index.html", user_id: user.id, room: user.sig_id, intro: @wk1
  end

  def index_b(conn, _) do
    user = conn.assigns.user
    conn
    |> put_layout(false)
    |> render "index.html", user_id: user.id, room: 100 + user.sig_id, intro: @wk2
  end
end
