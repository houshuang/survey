defmodule Survey.UserController do
  use Survey.Web, :controller

  require Logger
  alias Survey.User
  import Prelude

  plug :action

  def index(conn, params) do
    Logger.debug(inspect(conn, pretty: true))
    conn
    |> put_layout("minimal.html")
    |> render "form.html"
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
  
  def info(conn, _) do
    render conn, "info.html"
  end
  
  def delete_user(conn, _) do
    Repo.delete(conn.assigns.user)
    conn
    |> delete_session(:repo_userid)
    |> put_flash(:info, "User deleted")
    |> redirect to: "/user/info"
  end

  def delete_survey(conn, _) do
    Logger.debug(inspect(conn, pretty: true))
    user = conn.assigns.user
    Repo.update(%{user | surveystate: 0, survey: nil })
    conn
    |> put_flash(:info, "Survey deleted")
    |> redirect to: "/user/info"
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

  defp proc_tags(%{tags: tags} = h), do: %{h | tags: String.split(tags, "|") }
  defp proc_tags(x), do: x

  defp proc_other_role(%{other_role: other} = h) do 
    h
    |> append_map(:other, other) 
    |> Map.delete(:other_role)
  end

  defp proc_other_role(h), do: h

end
