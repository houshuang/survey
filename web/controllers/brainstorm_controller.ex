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

  def live_a(conn, _) do
    user = conn.assigns.user
    conn
    |> put_layout(false)
    |> render "live.html", user: user, embed: "https://www.youtube.com/embed/fN8Ap68p2_8", title: "Panel 1: MOOC Instructors and 1 teacher: Jim, Rosemary and Mike (Wednesday, 10:30 EST, 1430 GST)", room: 1001, chat_enabled: true, admin: admin?(user)
  end

  def live_b(conn, _) do
    user = conn.assigns.user
    conn
    |> put_layout(false)
    |> render "live.html", user: user, embed: "https://www.youtube.com/embed/4FcSGoTfqRQ", title: "Panel 2: UTS teachers, and Jim  (Thursday, 2:30 EST, 1830 GST)", room: 1002, chat_enabled: true, admin: admin?(user)
  end

  def admin?(user) do
    user.nick in ["jims", "houshuang", "renatoscarvalho", "ldjdhosdjf;kfelg;", "RosemaryEvans", "Jimslottagmail"]
  end

end
