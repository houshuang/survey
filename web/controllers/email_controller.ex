defmodule Survey.EmailController do
  use Survey.Web, :controller

  def unsubscribe(conn, _) do
    Survey.User.unsubscribe(conn.assigns.user, "all")
    html conn, "You have been unsubscribed from all personalized email from the INQ101x MOOC. To control mass-emails from EdX, please visit your user profile on EdX."
  end

  def unsubscribe_collab(conn, _) do
    Survey.User.unsubscribe(conn.assigns.user, "collab")
    html conn, "You have been unsubscribed from all e-mail notifications about
    people entering your design group."
  end
end

