defmodule Survey.ChatController do
  use Survey.Web, :controller

  plug :action

  def index(conn, params) do
    id = params["id"]
    render conn, "index.html", id: id
  end
end
