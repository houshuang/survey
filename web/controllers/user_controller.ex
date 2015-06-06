defmodule Survey.UserController do
  use Survey.Web, :controller

  require Logger
  alias Survey.User

  plug :action

  def index(conn, params) do
    Logger.debug(inspect(conn, pretty: true))
    conn
    |> put_layout("minimal.html")
    |> render "form.html"
  end

  def info(conn, _) do
    render conn, "info.html"
  end
  
  def submit(conn, params) do
    Logger.debug(inspect(conn, pretty: true))
    user = proc_register(params) 
    |> Map.put(:hash, get_session(conn, :lti_userid))
    |> Repo.insert
    conn = put_session(conn, :repo_userid, user.id)
    Logger.info("#{user.id} registered.")

    redir = get_session(conn, :ensure_registered_redirect)
    if redir do
      conn
      |> put_flash(:info, "Successfully registered!")
      |> delete_session(:ensure_registered_redirect)
      |> redirect to: redir
    else
      html conn, "Thank you for submitting"
    end
  end
  
  #-------------------------------------------------------------------------------- 

  def proc_register(params) do
    register = params["f"]
    |> proc_params
    |> atomify_map
    |> proc_tags
    |> proc_other_role
    |> yearsint
    struct(Survey.User, register)
  end

  defp yearsint(%{yearsteaching: y} = h), do: %{h | yearsteaching: string_to_int_safe(y) }
  defp yearsint(h), do: h

  def string_to_int_safe(y) do
    try do
      String.to_integer(y)
    rescue
      ArgumentError -> 0
      e -> raise e
    end
  end

  defp atomify_map(map) do
    Enum.map(map, fn {k,v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

  defp proc_tags(%{tags: tags} = h), do: %{h | tags: String.split(tags, "|") }
  defp proc_tags(x), do: x

  defp proc_other_role(%{other_role: other} = h) do 
    h
    |> append_map(:other, other) 
    |> Map.delete(:other_role)
  end

  defp proc_other_role(h), do: h

  # Takes an array of params from a form. Any params of the form steam|A, steam|M 
  # are concatenated into a list, like steam = ["A", "M"], other params are left alone
  def proc_params(x) when is_map(x), do: Enum.reduce(x, %{}, &proc_param/2)

  defp proc_param({sel, ""}, acc), do: acc

  defp proc_param({sel, val}, acc) do
    if String.contains?(sel, "|") do
      [part, rest] = String.split(sel, "|", parts: 2)
      append_map(acc, part, rest)
    else
      Map.put(acc, sel, val) 
    end
  end

  defp append_map(map, key, val) do
    Map.update(map, key, [val], fn x -> List.insert_at(x, 0, val) end)
  end
end
