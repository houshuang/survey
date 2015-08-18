defmodule Survey.ReviewController do
  use Survey.Web, :controller
  alias Survey.DesignGroup
  alias Survey.Review
  import Ecto.Query
  require Ecto.Query
  alias Survey.Repo
  require Logger
  import Prelude
  @form Survey.HTML.Survey.gen_survey("data/review.txt", :f)
  @form2 Survey.HTML.Survey.gen_survey("data/review2.txt", :f)
  @form3 Survey.HTML.Survey.gen_survey("data/review3.txt", :f)

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

  def wiki(conn, params) do
    user = conn.assigns.user
    submitted = if params["submitted"], do: true, else: false
    case DesignGroup.get_random_wiki(user.sig_id) do
      nil ->
        html conn, "No design groups ready in your SIG yet. Please
        try again later."
      {group, html} ->
        conn
        |> put_layout(false)
        |> render "index_wiki.html", form: @form3, html: html, group: group,
          submitted: submitted
    end
  end

  def wiki_submit(conn, params) do
    Logger.info("Submitted review for week 4")
    %Review{
      user_id: conn.assigns.user.id,
      design_group_id: string_to_int_safe(params["id"]),
      week: 4,
      review: params["f"]
    } |> Repo.insert!
    Survey.Grade.submit_grade(conn, "review_wk4", 1.0)
    ParamSession.redirect(conn, "/wiki-review?submitted=true")
  end

  def gallerywalk(conn, params, logged_in \\ true) do
    groupids = [10, 70, 114, 153, 216, 294, 2, 13, 18, 28, 75, 108, 121, 157, 202, 213, 21, 56,
      149, 170, 63, 181, 188, 231, 240]
    groups = (from f in Survey.DesignGroup, where: f.id in ^groupids)
              |> Survey.Repo.all
              |> Prelude.Map.group_by([:sig_id])
    sigs = Survey.SIG.map

    conn
    |> put_layout(false)
    |> render "gallerywalk.html", groups: groups, sigs: sigs, logged_in: logged_in
  end

  def gallerywalk_public(conn, params) do
    gallerywalk(conn, params, false)
  end

  def gallerywalk_detail(conn, %{"id" => id}) do
    group = Survey.DesignGroup.get(id)
    htmlstr = Survey.Cache.get(group.wiki_cache_id)
    comments = Survey.Commentstream.get("gallerywalk", id)
    title = group.title
    conn
    |> render "gallerywalk_detail.html", htmlstr: htmlstr, comments: comments, title: title
  end

  def gallerywalk_initial(conn, _) do
    html conn, "<h3>Please select a group on the left to view their design project, and leave at least one comment to get graded</h3>"
  end
end
