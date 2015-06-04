defmodule Survey.UserController do
  use Survey.Web, :controller

  alias Survey.User

  plug :action

  def index(conn, params) do
    conn
    |> put_layout("minimal.html")
    |> render "form.html"
  end
end
