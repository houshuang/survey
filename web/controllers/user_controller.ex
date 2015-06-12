defmodule Survey.UserController do
  use Survey.Web, :controller

  require Logger
  alias Survey.User
  import Prelude

  plug :action

  def index(conn, params) do
    conn
    |> put_layout("minimal.html")
    |> render "form.html"
  end

  def submit(conn, params) do
    user = proc_register(params) 
    |> Map.put(:hash, get_session(conn, :lti_userid))
    |> Map.put(:edx_email, get_session(conn, :edx_email))
    |> Map.put(:edx_userid, get_session(conn, :edx_userid))
    |> Repo.insert

    Logger.info("#{user.id} registered.")

    conn = conn
    |> put_session(:repo_userid, user.id)
    |> delete_session(:edx_email)
    |> delete_session(:edx_userid)

    redir = get_session(conn, :ensure_registered_redirect)
    if redir do
      conn
      |> put_flash(:info, "Successfully registered!")
      |> delete_session(:ensure_registered_redirect)
      |> ParamSession.redirect to: redir
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
    |> ParamSession.redirect to: "/user/info"
  end

  def delete_survey(conn, _) do
    user = conn.assigns.user
    Repo.update(%{user | surveystate: 0, survey: nil })
    conn
    |> put_flash(:info, "Survey deleted")
    |> ParamSession.redirect to: "/user/info"
  end
  #-------------------------------------------------------------------------------- 

  def proc_register(params) do
    register = params["f"]
    |> proc_params
    |> atomify_map
    |> proc_tags
    |> Map.update(:role, [], fn x -> [x] end)
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
    |> append_map(:role, other) 
    |> Map.delete(:other_role)
  end

  defp proc_other_role(h), do: h

end
