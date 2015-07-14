defmodule Survey.AdminController do
  use Survey.Web, :controller

  plug :action

  def cohorts(conn, _params) do
    cohorts = Survey.User.cohorts_csv
    text conn, cohorts
  end

  def wk1(conn, _) do
    Mail.send_wk1(conn)
    html conn, "OK"
  end

  def wk2(conn, _) do
    Mail.send_wk2
    html conn, "OK"
  end
end
