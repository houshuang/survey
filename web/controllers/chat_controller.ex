defmodule Survey.ChatController do
  use Survey.Web, :controller

  plug :action

  def index(conn, params) do
    id = params["id"]
    user = params["user"]
    conn
    |> render "index.html", id: id, user: user
  end
end
