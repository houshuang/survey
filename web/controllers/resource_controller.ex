defmodule Survey.ResourceController do
  use Survey.Web, :controller

  require Logger
  alias Survey.Resource
  import Prelude

  plug :action

  def add(conn, params) do
    if params["f"] do
      Logger.info("Saving new resource")
      save_to_db(conn, params["f"])
      # Survey.Grade.submit_grade(conn, "add_resource", 1.0)
      conn = put_flash(conn, :info, 
        "Thank you for submitting a resource. Your participation has already been graded. You are welcome to submit more resources, or move on to other parts of the course.")
    end

    sig = conn.assigns.user.sig_id
    tags = Survey.ResourceTag.get_tags(sig)

    conn
    |> put_layout("minimal.html")
    |> render "resource.html", tags: tags
  end


  def preview(conn, params) do
    tags = Survey.ResourceTag.get_tags(2)
    conn
    |> put_layout("minimal.html")
    |> render "resource.html", tags: tags
  end

  def report(conn, _) do
    resources = Survey.Resource.get_all_by_sigs
    conn
    |> put_layout("minimal.html")
    |> render "report.html", resources: resources
  end
  #---------------------------------------- 

  def save_to_db(conn, params) do
    resource = params
    |> Map.update("generic", false, fn x -> x == "true" end)
    |> Map.put("user_id", conn.assigns.user.id)
    |> Map.put("sig_id", conn.assigns.user.sig_id)
    |> atomify_map
    |> proc_tags

    struct(Survey.Resource, resource)
    |> Survey.Repo.insert
  end

  defp proc_tags(%{tags: tags} = h), do: %{h | tags: String.split(tags, "|") }
  defp proc_tags(x), do: x

  def check_url(conn, params) do
    url = params["url"] |> String.strip
    if id = Resource.find_url(url) do
      json conn, %{result: "exists", id: id}
    else
      try do
        %HTTPoison.Response{status_code: status} = 
        HTTPoison.head!(url, timeout: 3000)
        if bad_status(status) do
          json conn, %{result: "not found"}
        else
          json conn, %{result: "success"}
        end
      rescue 
        e -> IO.inspect(e)
          json conn, %{result: "not found"}
      end
    end
  end

  defp bad_status(s) do
    s |> Integer.to_string |> String.starts_with?("4")
  end
end
