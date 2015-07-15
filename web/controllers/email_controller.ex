defmodule Survey.EmailController do
  use Survey.Web, :controller
  @hashid Hashids.new(salt: Application.get_env(:mailer, :hashid_salt))
  require Ecto.Query
  import Ecto.Query

  def unsubscribe(conn, _) do
    Survey.User.unsubscribe(conn.assigns.user, "all")
    html conn, "You have been unsubscribed from all personalized email from the INQ101x MOOC. To control mass-emails from EdX, please visit your user profile on EdX."
  end

  def unsubscribe_collab(conn, _) do
    Survey.User.unsubscribe(conn.assigns.user, "collab")
    html conn, "You have been unsubscribed from all e-mail notifications about
    people entering your design group."
  end

  def redirect(conn, %{"hash" => hash}) do
    {:ok, [id]} = Hashids.decode(@hashid, String.strip(hash))
    struct = Survey.Cache.get(id)
    hash = (from f in Survey.User, 
    where: f.id == ^struct.userid,
    select: f.hash) |> Repo.one
    conn 
    |> put_session(:repo_id, struct.userid)
    |> put_session(:lti_userid, hash)
    |> ParamSession.redirect(String.replace(struct.url, "}", ""))
  end 

end

