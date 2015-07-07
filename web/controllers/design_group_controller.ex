defmodule Survey.DesignGroupController do
  use Survey.Web, :controller
  alias Survey.DesignGroup
  require Logger
  import Prelude

  def add_idea(conn, params) do
    user = conn.assigns.user
    if params["f"] do
      Logger.info("Saving new design idea")

      form = params["f"]
      {title, form} = Map.pop(form, "title")

      req = %DesignGroup{
        title: title, 
        description: form, 
        sig_id: user.sig_id,
        user_id: user.id }
      |> DesignGroup.insert_once
    end

    already = DesignGroup.submitted_count(user.id)
    if already && already > 0 do
      url = ParamSession.gen_url(conn, "/design_groups/select")
      conn = put_flash(conn, :info, 
        "Thank you for submitting #{already} #{resource_word(already)}. You are welcome to submit more ideas, or move on to <a href='#{url}' target='_blank'>select a design group to join</a>, and begin co-designing a lesson plan with other students.")
    end

    conn
    |> put_layout("minimal.html")
    |> render "add_idea.html"
  end

  def resource_word(cnt) when cnt > 1, do: "design ideas"
  def resource_word(cnt), do: "design idea"

  def add_idea_submit(conn, params) do
    html conn, "OK"
  end

  def select(conn, params) do
    if Survey.DesignGroup.get_by_user(conn.assigns.user.id).design_group_id do
      ParamSession.redirect(conn, "/collab")
    else
      conn
      |> put_layout(false)
      |> render "select.html"
    end
  end

  def select_sidebar(conn, params) do
    sig = conn.assigns.user.sig_id
    designs = DesignGroup.list(sig)
    signame = Survey.SIG.name(sig)
    conn
    |> put_layout(false)
    |> render "sidebar.html", sig: signame, designs: designs
  end

  def select_detail(conn, params) do
    id = string_to_int_safe(params["id"])
    design = DesignGroup.get(id || 0)
    if !design do
      html conn, "Design idea not found"
    else
      userlen = length(DesignGroup.get_members(design.id || 0))
      conn
      |> put_layout(false)
      |> render "detail.html", design: design, userlen: userlen
    end
  end

  def overview(conn, _) do
    html conn, "Please select a group on the left. If there are no groups listed, users in your SIG have not added any ideas yet. You can go to the previous section in EdX and add design group ideas, and then come back here to select one to work on."
  end

  def submit(conn, params) do
    id = string_to_int_safe(params["id"])
    Logger.info("Joined design group #{id}")
    %{ conn.assigns.user | design_group_id: id } |> Repo.update!
    
    ParamSession.redirect(conn, "/collab")
  end

  def report(conn, params) do
    groups = DesignGroup.get_all
    sigmap = Survey.SIG.map
    chats = Survey.Chat.get_each

    conn
    |> put_layout("minimal.html")
    |> render "report.html", groups: groups, sigmap: sigmap
  end
end
