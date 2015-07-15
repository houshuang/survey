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

    questions = Survey.RenderSurvey.render_survey(questions, {query, :response})

    conn 
    |> put_layout("report.html")
    |> render Survey.ReportView, "index.html", questions: questions, 
      texturl: "/admin/report/reflections/text/#{id}/"
  end

  def reflections(conn, params) do
    render conn, "reflection_list.html", reflections: Survey.Prompt.list
  end

  def fulltext(conn, %{"qid" => qid, "id" => id} = params) do 
    qid = string_to_int_safe(qid)
    id = string_to_int_safe(id)
    query = (from f in Survey.Reflection, where: f.prompt_id == ^id)
    prompt = Survey.Prompt.get(id)
    questions = prompt.question_def

    assigns = Survey.RenderSurvey.prepare_text({qid, questions[qid]}, 
      params["search"], {query, :response})
    conn 
    |> put_layout("report.html")
    |> render Survey.ReportView, "textanswer.html", assigns  
  end
end
