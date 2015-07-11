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
    designgroup = DesignGroup.get_by_user(conn.assigns.user.id).design_group_id

    conn
    |> put_layout(false)
    |> render "select.html", designgroup: designgroup
  end

  def select_sidebar(conn, params) do
    sig = conn.assigns.user.sig_id
    designs = DesignGroup.list(sig)
    signame = Survey.SIG.name(sig)
    userid = conn.assigns.user.id
    conn
    |> put_layout(false)
    |> render "sidebar.html", sig: signame, designs: designs, userid: userid
  end

  def select_detail(conn, params) do
    userid = conn.assigns.user.id 
    id = string_to_int_safe(params["id"])
    embedded = if params["embedded"], do: true, else: false
    already = DesignGroup.get_by_user(userid).design_group_id
    design = DesignGroup.get(id || 0)
    mine = design.user_id == userid
    if !design do
      html conn, "Design idea not found"
    else
      userlen = length(DesignGroup.get_members(design.id || 0))
      conn
      |> put_layout(false)
      |> render "detail.html", design: design, userlen: userlen, 
        embedded: embedded, already: already, mine: mine
    end
  end

  def overview(conn, _) do
    d_id = DesignGroup.get_by_user(conn.assigns.user.id).design_group_id
    text = if d_id do
      title = DesignGroup.get(d_id).title
      url = ParamSession.gen_url(conn, collab_path(conn, :index))
      "You are already a member of the group <b>#{title}</b>. 
      <a href='#{url}' target='_blank'>Click here</a> to go to the
      collaborative workbench for your group. You can also browse the other
      groups in your SIG, and decide to join one of those groups. In that case,
      you will automatically leave your current group."
    else
      "Please select a group on the left. If there are no groups listed, users
      in your SIG have not added any ideas yet. You can go to the previous
      section in EdX and add design group ideas, and then come back here to
      select one to work on."
    end
    html conn, text
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

  def submit_edit(conn, params) do
    group = DesignGroup.get(params["id"])
    item = params["item"]
    desc = Map.put(group.description, item, params["value"])
    %{ group | description: desc } |> Repo.update!
    json conn, "Success"
  end
end
