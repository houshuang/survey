defmodule Survey.ReflectionController do
  use Survey.Web, :controller

  require Logger
  alias Survey.Prompt
  import Prelude
  alias Survey.Repo
  alias Survey.Prompt
  alias Survey.Reflection

  plug :action

  def index(conn, params) do
    if !params["id"] do
      id = 1
    else 
      id = params["id"]
      end
    prompt = Repo.get(Prompt, id)
    reflection = Reflection.get(conn.assigns.user.id, prompt.id)
    if reflection do
      conn = put_flash(conn, :info, 
        "Thank you for submitting your reflection this week, you have already been graded. Feel free to modify and submit again.")
    end

    render conn, "index.html", html: prompt.html, id: id,
      reflection: reflection
  end

  def submit(conn, params) do
    id = params["reflection_id"]
    form = params["f"]
    Reflection.store(conn.assigns.user.id, String.to_integer(id), form)
    Survey.Grade.submit_grade(conn, "reflection_#{id}", 1.0)
    html conn, "Thank you for submitting!"

  end

  def assessment(conn, _) do
    id = 101
    prompt = Repo.get(Prompt, id)
    reflection = Reflection.get(conn.assigns.user.id, prompt.id)
    if reflection do
      conn = put_flash(conn, :info, 
        "Thank you for submitting your assessment this week, you have already been graded. Feel free to modify and submit again.")
    end
    render conn, "assessment.html", html: prompt.html, id: id,
      reflection: reflection
  end

  def assessment_submit(conn, params) do
    id = params["reflection_id"]
    form = params["f"]
    Reflection.store(conn.assigns.user.id, String.to_integer(id), form)
    grade = case form["1"] do
      "a" -> 0.0
      "b" -> 0.5
      "c" -> 1.0
    end
    Survey.Grade.submit_grade(conn, "assessment_#{id}", grade)
    html conn, "Thank you for submitting!"
  end
end