defmodule Survey.ChatController do
  use Survey.Web, :controller

  plug :action

  def index(conn, params) do
    id = params["id"]
    user = params["user"]
    if !user do
      html conn, "Please supply a user as a URL parameter, for example /chat/1?user=stian"
    else
      conn
      |> render "index.html", id: id, user: user
    end
  end
end
