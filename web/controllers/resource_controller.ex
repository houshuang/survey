defmodule Survey.ResourceController do
  use Survey.Web, :controller

  require Logger
  alias Survey.Resource
  import Prelude
  alias Survey.Resource
  alias Survey.ResourceTag
  alias Survey.Repo

  plug :action

  def add(conn, params) do
    if params["f"] do
      Logger.info("Saving new resource")
      save_to_db(conn, params["f"])
      Survey.Grade.submit_grade(conn, "add_resource", 1.0)
    end

    already = Resource.user_submitted_no(conn.assigns.user.id)
    if already > 0 do
      conn = put_flash(conn, :info, 
        "Thank you for submitting #{already} #{resource_word(already)}. Your participation has already been graded. You are welcome to submit more resources, or move on to other parts of the course.")
    end

    sig = conn.assigns.user.sig_id
    tags = ResourceTag.get_tags(sig)

    conn
    |> put_layout("minimal.html")
    |> render "resource.html", tags: tags
  end

  def resource_word(cnt) when cnt > 1, do: "resources"
  def resource_word(cnt), do: "resource"

  #---------------------------------------- 

  def tag_cloud(conn, params) do
    sig = conn.assigns.user.sig_id
    if params["all"], do: sig = nil
    tagfreq = Resource.tag_freq(sig)
    conn
    |> put_layout("minimal.html")
    |> render "tag_cloud.html", tagfreq: tagfreq
  end
  
  def list(conn, params) do
    sig = conn.assigns.user.sig_id
    if params["tag"] do
      tag = params["tag"]
      resources = Resource.resource_list(sig, params["tag"])
    else
      tag = nil
      resources = Resource.resource_list(sig)
    end

    conn
    |> put_layout("minimal.html")
    |> render "list.html", resources: resources, tag: tag
  end
  #---------------------------------------- 

  def review(conn, params) do 
    if params["list"] do
      conn = put_session(conn, :review_redirect, true)
      redirect = :list
    else
      redirect = :next
      conn = delete_session(conn, :review_redirect)
    end
    user = conn.assigns.user
    already = Resource.user_reviewed_no(conn.assigns.user.id)
    if already > 0 do
      conn = put_flash(conn, :info, 
        "Thank you for reviewing #{already} #{resource_word(already)}. You are welcome to review more resources, or move on to other parts of the course.")
      Survey.Grade.submit_grade(conn, "review_resource", 1.0)
    end
    
    if params["id"] do
      id = String.to_integer(params["id"])
      Resource.update_seen(user, id)
    else
      id = Resource.get_random(conn.assigns.user)
    end

    if !id do
      html conn, "Sorry, we could not find any new resources for you to review. Try back in a little while."
    else
      sig = conn.assigns.user.sig_id
      tags = ResourceTag.get_tags(sig)
      resource = Resource.get_resource(id)

      if !resource do
        ParamSession.redirect(conn, "/resource/review")
      else
      seen = Resource.user_seen?(user, resource.id)

        rtype = if resource.generic do
          "NOTE: This is a GENERIC Resource, meaning that the person who added it felt that it would be applicable to more than one SIG"
        else
          ""
        end

        conn
        |> put_layout("minimal.html")
        |> render "review.html", tags: tags, resource: resource,
          resourcetype: rtype, redirect: redirect, seen: seen
      end
    end
  end

  def review_submit(conn, params) do
    user = conn.assigns.user
    resource = Repo.get(Resource, params["resource_id"])
    form = params["f"] 
    |> Enum.map(fn {k, v} -> {k, String.strip(v)} end)
    |> Enum.into(%{})

    # COMMENTS
    comments = resource.comments || []
    if string_param_exists(form["comment"]) do
      newcom = %{nick: user.nick, user_id: user.id, text: form["comment"],
        date: Ecto.DateTime.local}
      comments = [ newcom | comments ]
    end

    # DESCRIPTION
    description = resource.description
    old_desc = resource.old_desc
    if string_param_exists(form["description"]) &&
      String.strip(form["description"]) != String.strip(resource.description) do
      description = String.strip(form["description"])

      cur = %{description: form["description"], user_id: user.id, 
        date: Ecto.DateTime.local}

      # either append, or create old_desc with orig as first entry
      if old_desc do
        old_desc = [ cur | old_desc ]
      else
        orig = %{description: resource.description, 
          user_id: resource.user_id, date: resource.inserted_at}
        old_desc = [cur, orig]
      end
    end

    # SCORE
    score = resource.score || 0.0
    old_score = resource.old_score || []
    if string_param_exists(form["rating"]) do
      {newscore, _} = Float.parse(form["rating"])
      new_old_score = %{ "user" => user.id, "score" => newscore, 
        "date" => Ecto.DateTime.local }
      old_score = [ new_old_score | old_score ]
      score_sum = old_score
      |> Enum.map(fn x -> x["score"] end)
      |> Enum.sum
      score = score_sum / length(old_score)
    end

    # TAGS
    tags = resource.tags
    if !(resource.generic || !form["tags"] || form["tags"] == "") do
      old_tags = resource.old_tags
      raw_tags = String.split(form["tags"], "|")
      new_tags = set_difference(raw_tags, tags)
      if !Enum.empty?(new_tags) do
        
        tags = raw_tags
        cur = %{tags: new_tags, user_id: user.id, 
          date: Ecto.DateTime.local}

        # either append, or create old_desc with orig as first entry
        if old_tags do
          old_tags = [ cur | old_tags ]
        else
          orig = %{tags: resource.tags, 
            user_id: resource.user_id, date: resource.inserted_at}
          old_tags = [cur, orig]
        end
      end
    end
    
    # INSERT DB
    %{ resource | 
      tags: tags, old_tags: old_tags, score: score, old_score: old_score,
      description: description, old_desc: old_desc, comments: comments}
    |> Repo.update!

    redir_url = if get_session(conn, :review_redirect) do
      "/resource/list"
    else
      "/resource/review"
    end
    Survey.Grade.submit_grade(conn, "review_resource", 1.0)
    
    conn
    |> ParamSession.redirect redir_url
  end
  #---------------------------------------- 

  def set(x) when is_list(x) do
    Enum.into(x, HashSet.new)
  end

  def different_as_set?(x, y) when is_list(x) and is_list(y) do
    !Enum.empty?(set_difference(x, y))
  end

  def set_difference(x, y) when is_list(x) and is_list(y) do
    Set.difference(set(x), set(y))
    |> Enum.to_list
  end

  def preview(conn, params) do
    tags = ResourceTag.get_tags(2)
    conn
    |> put_layout("minimal.html")
    |> render "resource.html", tags: tags
  end

  def report(conn, _) do
    resources = Resource.get_all_by_sigs
    conn
    |> put_layout("minimal.html")
    |> render "report.html", resources: resources
  end
  #---------------------------------------- 

  def save_to_db(conn, params) do
    if !Resource.find_url(params["url"], conn.assigns.user.sig_id) do
      resource = params
      |> Map.update("generic", false, fn x -> x == "true" end)
      |> Map.put("user_id", conn.assigns.user.id)
      |> Map.put("sig_id", conn.assigns.user.sig_id)
      |> atomify_map
      |> proc_tags

      struct(Resource, resource)
      |> Repo.insert!

      ResourceTag.update_tags(conn.assigns.user.sig_id, resource.tags)
    else
      Logger.warn("Tried inserting resource with same URL twice")
    end
  end

  defp proc_tags(%{tags: tags} = h), do: %{h | tags: String.split(tags, "|") }
  defp proc_tags(x), do: x

  def check_url(conn, params) do
    sig = conn.assigns.user.sig_id
    url = params["url"] |> String.strip
    if id = Resource.find_url(url, sig) do
      json conn, %{result: "exists", id: id}
    else
      json conn, %{result: "success"}
    end
  end

  defp bad_status(s) do
    s |> Integer.to_string |> String.starts_with?("4")
  end

  defp string_param_exists(s) do
    s && String.strip(s) != ""
  end
end
