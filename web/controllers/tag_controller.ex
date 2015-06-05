defmodule Survey.TagController do
  use Survey.Web, :controller
  require Logger
  require Ecto.Query
  import Ecto.Query
  alias Survey.Repo
  alias Survey.User

  plug :action

  def index(conn, _) do
    render conn, "index.html"
  end

  def submit(conn, params) do
    set_survey(conn, params)
    render conn, "survey_success.html"
  end

  def submitajax(conn, params) do
    set_survey(conn, params)
    text conn, "Success"
  end

  defp set_survey(conn, surveydata) do
    Logger.warn("Saving to database")
    userid = get_session(conn, :repo_userid)

    user = Repo.one userid
    Repo.update(%{user | survey: surveydata }) 
  end

end
