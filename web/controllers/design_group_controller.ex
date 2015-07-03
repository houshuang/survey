defmodule Survey.DesignGroupController do
  use Survey.Web, :controller
  alias Survey.DesignGroup
  require Logger

  def add_idea(conn, params) do
    user = conn.assigns.user
    if params["f"] do
      Logger.info("Saving new design idea")

      form = params["f"]
      {title, form} = Map.pop(form, "title")

      %DesignGroup{
        title: title, 
        description: form, 
        sig_id: user.sig_id,
        user_id: user.id }
      |> Repo.insert!
    end

    already = DesignGroup.submitted_count(user.id)
    if already && already > 0 do
      conn = put_flash(conn, :info, 
        "Thank you for submitting #{already} #{resource_word(already)}. You are welcome to submit more ideas, or move on to select a design group to join, and begin co-designing a lesson plan with other students.")
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
end

