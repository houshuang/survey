defmodule Survey.TagController do
  use Survey.Web, :controller
  require Logger
  plug :action

  def index(conn, params) do
    conn = put_session(conn, :user_id, "stian")
    render conn, "index.html"
  end

  def submit(conn, params) do
    Logger.warn(get_session(conn, :user_id))
    text conn, "User id: #{get_session(conn, :user_id)}: #{inspect(params, pretty: true)}"
  end
end
