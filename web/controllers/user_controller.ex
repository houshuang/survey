defmodule Survey.UserController do
  use Survey.Web, :controller

  require Logger
  alias Survey.User
  import Prelude

  plug :action

  def index(conn, _) do
    hash = get_session(conn, :lti_userid)

    user = Survey.Repo.get_by(Survey.User, hash: hash)
    if user do
      Logger.info("#{user.id} tried to double-register (1).")
      html conn, "Already registered"
    else
      conn
      |> put_layout("minimal.html")
      |> render "form.html"
    end
  end

  def get_tags(conn, params) do
    params = params["f"]
    |> proc_params
    |> atomify_map
    |> proc_tags
    json conn, Survey.Tag.get_tags(params.grade, params.steam)
  end

  def submit(conn, params) do
    hash = get_session(conn, :lti_userid)

    user = Survey.Repo.get_by(Survey.User, hash: hash)
    if !user do
      user = proc_register(params) 
      |> Map.put(:hash, hash)
      |> Map.put(:edx_email, get_session(conn, :edx_email))
      |> Map.put(:edx_userid, get_session(conn, :edx_userid))
      |> Map.put(:admin, get_session(conn, :admin))
      |> Repo.insert

      Logger.info("#{user.id} registered.")
      if user.tags do
        Survey.Tag.update_tags(user.grade, user.steam, user.tags)
      end

      conn = conn
      |> put_session(:repo_userid, user.id)
      |> delete_session(:edx_email)
      |> delete_session(:edx_userid)
      |> delete_session(:admin)
    else
      Logger.info("#{user.id} tried to double-register (2).")
    end

    redir = get_session(conn, :ensure_registered_redirect)
    if redir do
      conn
      |> put_flash(:info, "Successfully registered!")
      |> delete_session(:ensure_registered_redirect)
      |> ParamSession.redirect redir
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
    |> ParamSession.redirect "/user/info"
  end

  def delete_survey(conn, _) do
    user = conn.assigns.user
    Repo.update(%{user | surveystate: 0, survey: nil })
    conn
    |> put_flash(:info, "Survey deleted")
    |> ParamSession.redirect "/user/info"
  end

  def select_sig(conn, _) do
    hash = get_session(conn, :lti_userid)

    conn
    |> put_layout("minimal.html")
    |> render "select_sig.html"
  end

  def select_sig_freestanding(conn, _) do
    sig = Map.get(conn.assigns.user, :sig_id, nil)
    signame = if sig do
      Repo.get(Survey.SIG, sig).name
    else
      nil
    end

    conn
    |> put_layout("minimal.html")
    |> render "select_sig_freestanding.html", sig: signame
  end

  def select_sig_submit(conn, params) do
    sig = params["f"]["sig_id"]

    userid = get_session(conn, :repo_userid)
    user = Repo.get(Survey.User, userid)

    %{ user | sig_id: string_to_int_safe(sig) } |> Repo.update

    redir = get_session(conn, :ensure_sig_redirect)
    if redir do
      conn
      |> delete_session(:ensure_sig_redirect)
      |> ParamSession.redirect redir
    else
      html conn, "Thank you for submitting. Your SIG choice has been updated."
    end
  end

  #-------------------------------------------------------------------------------- 

  def proc_register(params) do
    register = params["f"]
    |> proc_params
    |> atomify_map
    |> proc_tags
    |> Map.update(:role, [], fn x -> [x] end)
    |> bools
    |> proc_other_role
    |> yearsint
    |> sigint
    struct(Survey.User, register)
  end

  defp bools(%{allow_email: "true"} = h), do: %{h | allow_email: true }
  defp bools(h), do: h

  defp yearsint(%{yearsteaching: y} = h), do: %{h | yearsteaching: string_to_int_safe(y) }
  defp yearsint(h), do: h

  defp sigint(%{sig_id: y} = h), do: %{h | sig_id: string_to_int_safe(y) }
  defp sigint(h), do: h

  defp proc_tags(%{tags: tags} = h), do: %{h | tags: String.split(tags, "|") }
  defp proc_tags(x), do: x

  defp proc_other_role(%{other_role: other} = h) do 
    h
    |> append_map(:role, other) 
    |> Map.delete(:other_role)
  end

  defp proc_other_role(h), do: h

end
