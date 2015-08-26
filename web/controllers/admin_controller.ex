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

  # ---------------------------------------------------------------

  def reflections(conn, params = %{"id" => id}) do
    id = string_to_int_safe(id)
    prompt = Survey.Prompt.get(id)
    questions = prompt.question_def
    query = (from f in Survey.Reflection, where: f.prompt_id == ^id)
    total = (from f in query, select: count(f.id)) |> Survey.Repo.one

    questions = Survey.RenderSurvey.render_survey(questions, {query, :response})

    conn
    |> put_layout("report.html")
    |> render Survey.ReportView, "index.html", questions: questions,
      texturl: "/admin/report/reflections/text/#{id}/", total: total
  end

  def exit(conn, _) do
    questions = Survey.HTML.Survey.parse("data/exitsurvey.txt") |> Survey.HTML.Survey.index_mapping
    query = (from f in Survey.User, where: f.exitsurvey_state == true)
    total = (from f in query, select: count(f.id)) |> Survey.Repo.one

    questions = Survey.RenderSurvey.render_survey(questions, {query, :exitsurvey})

    conn
    |> put_layout("report.html")
    |> render Survey.ReportView, "index.html", questions: questions,
      texturl: "exit/text/", total: total
  end

  def exit_text(conn, %{"qid" => qid} = params) do
    qid = string_to_int_safe(qid)
    query = (from f in Survey.User, where: f.exitsurvey_state == true)
    questions = Survey.HTML.Survey.parse("data/exitsurvey.txt") |> Survey.HTML.Survey.index_mapping
    assigns = Survey.RenderSurvey.prepare_text({qid, questions[qid]},
      params["search"], {query, :exitsurvey})
    conn
    |> put_layout("report.html")
    |> render Survey.ReportView, "textanswer.html", assigns
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

  #----------------------------------------------------------------------
  def group_activity(conn, params) do
    conn
    |> put_layout(false)
    |> render "group_activity.html", groups: Survey.DesignGroup.get_all_active_full,
    reviews: Survey.Review.get_all, max_review: Survey.Review.max_review,
    etherpad_max: Survey.Etherpad.max_weeks,
    num_members: Survey.DesignGroup.get_num_members,
    online: Survey.ChatPresence.get_all_users_by_room,
    chats: Survey.Chat.get_length,
    emails: Survey.Email.num_by_group

  end

end
