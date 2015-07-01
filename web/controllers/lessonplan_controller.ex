defmodule Survey.LessonplanController do
  use Survey.Web, :controller

  def index(conn, _) do
    conn
    |> put_layout(false)
    |> render "index.html"
  end

  def overview(conn, _) do
    conn
    |> put_layout(false)
    |> render "overview.html"
  end

  def sidebar(conn, _) do
    conn
    |> put_layout(false)
    |> render "sidebar.html"
  end

  def detail(conn, params) do
    id = params["id"]
    css = id 
    |> String.split("-") 
    |> Enum.take(2) 
    |> Enum.join("-")

    lesson = File.read!("priv/static/lessonplans/#{id}.html")

    conn
    |> put_layout(false)
    |> render "detail.html", css: css, lesson: lesson
  end

end
