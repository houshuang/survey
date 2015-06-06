defmodule Survey.TagController do
  use Survey.Web, :controller
  require Logger
  require Ecto.Query
  import Ecto.Query
  alias Survey.Repo
  alias Survey.User

  plug :action

  def index(conn, _) do
    if conn.assigns.user.surveystate == 99 do
      render conn, "survey_success.html"
    else
      render conn, "index.html"
    end
  end

  def submit(conn, params) do
    set_survey(conn, params, true)
    render conn, "survey_success.html"
  end

  def submitajax(conn, params) do
    set_survey(conn, params)
    text conn, "Success"
  end

  defp set_survey(conn, params, complete \\ false) do
    Logger.warn("Saving to database")
    userid = get_session(conn, :repo_userid)

    user = conn.assigns.user
    user = %{user | survey: clean_survey(params["f"]) }
    if complete do
      user = %{user | surveystate: 99 }
    end
    Logger.debug(inspect(user))
    Repo.update(user) 
  end

  defp clean_survey(survey) do
    Enum.filter(survey, &not_empty/1)
    |> Enum.into(%{})
  end

  defp not_empty({_, ""}), do: false
  defp not_empty(_), do: true

end
