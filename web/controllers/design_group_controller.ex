defmodule Survey.DesignGroupController do
  use Survey.Web, :controller
  alias Survey.DesignGroup

  def add_idea(conn, parmas) do
    conn
    |> put_layout("minimal.html")
    |> render "add_idea.html"
  end

  def add_idea_submit(conn, params) do
    conn
  end
end

