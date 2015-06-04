defmodule Survey.TagController do
  use Survey.Web, :controller
  require Logger
  plug :action

  def index(conn, params) do
    conn = put_session(conn, :user_id, "stian")
    render conn, "index.html"
  end

  def submit(conn, params) do
    save(params)
    render conn, "survey_success.html"
  end

  def submit(conn, params) do
    save(params)
    text conn, "Success"
  end

  defp save(params) do
    Logger.warn(inspect(params, pretty: true))
  end
end
