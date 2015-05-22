defmodule Survey.TagController do
  use Survey.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end

  def submit(conn, params) do
    json conn, inspect(params)
  end
end
