defmodule Survey.AdminController do
  use Survey.Web, :controller
  import Prelude
  import Ecto.Query
  require Ecto.Query

  plug :action

  def cohorts(conn, _params) do
    cohorts = Survey.User.cohorts_csv
    text conn, cohorts
  end

  def wk1(conn, _) do
    Mail.send_wk1(conn)
    html conn, "OK"
  end

  def wk2(conn, _) do
    Mail.send_wk2
    html conn, "OK"
  end

  # ---------------------------------------------------------------

  def reflections(conn, params = %{"id" => id}) do
    id = string_to_int_safe(id)
    prompt = Survey.Prompt.get(id)
    questions = prompt.question_def
    query = (from f in Survey.Reflection, where: f.prompt_id == ^id)
    html conn, inspect(Survey.RenderSurvey.render_survey(questions, {query, :response}))
  end

  def reflections(conn, params) do
    render conn, "reflection_list.html", reflections: Survey.Prompt.list
  end
end
