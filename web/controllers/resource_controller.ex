defmodule Survey.ResourceController do
  use Survey.Web, :controller

  require Logger
  alias Survey.User
  import Prelude

  plug :action

  def resource(conn, params) do
    sig = conn.assigns.user.sig_id
    tags = Survey.ResourceTag.get_tags(sig)
    conn
    |> put_layout("minimal.html")
    |> render "resource.html", tags: tags
  end

  def resource_preview(conn, params) do
    tags = Survey.ResourceTag.get_tags(2)
    conn
    |> put_layout("minimal.html")
    |> render "resource.html", tags: tags
  end

  def resource_review(conn, params) do
    conn
    |> put_layout("minimal.html")
    |> render "resource-review.html"
  end
end
