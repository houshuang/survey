defmodule Survey.CommentstreamController do
  use Survey.Web, :controller
  alias Survey.Commentstream

  def submit(conn, params) do
    p = params["f"]
    if p["comment"] && String.strip(p["comment"]) != "" do
      Commentstream.add(p["resourcetype"], p["identifier"], p["comment"], conn.assigns.user.id, conn.assigns.user.nick)
      Survey.Grade.submit_grade(conn, "gallerywalk", 1.0)
      json conn, "Submitted"
    else
      json conn, "No comment"
    end
  end
end
