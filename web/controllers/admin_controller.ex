defmodule Survey.AdminController do
  use Survey.Web, :controller

  plug :action

  def cohorts(conn, _params) do
    cohorts = Survey.User.cohorts_csv
    text conn, cohorts
  end
end
