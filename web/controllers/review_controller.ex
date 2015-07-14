defmodule Survey.ReviewController do
  use Survey.Web, :controller
  alias Survey.DesignGroup
  alias Survey.Review
  alias Survey.Repo
  require Logger
  import Prelude
  @form Survey.HTML.Survey.gen_survey("data/review.txt", :f)

  def index(conn, params = %{"id" => id}) do
    group = DesignGroup.get(id)
    if !group.id do
      html conn, "This design group does not exist"
    else
      conn
      |> put_layout(false)
      |> render "index.html", group: group, form: @form
    end
  end

  def cancel(conn, _) do
    ParamSession.redirect(conn, "/design_groups/select")
  end

  def submit(conn, params) do
    %Review{
      user_id: conn.assigns.user.id,
      design_group_id: string_to_int_safe(params["id"]),
      week: 1,
      review: params["f"]
    } |> Repo.insert!
    Survey.Grade.submit_grade(conn, "review_wk1", 1.0)
    ParamSession.redirect(conn, "/design_groups/select?submitted=true")
  end
end


