defmodule EnsureRegistered do
  @moduledoc """
  A plug run before every regular page request, to ensure that the user is registered with our system.
  If not, user is redirected to our registration page, and after successful registration, is redirected
  back to the original target.

  Initially checks whether user_id is stored in the cookie, if not, looks up user in database.
  """

  use Behaviour
  @behaviour Plug
  import Plug.Conn

  require Ecto.Query
  import Ecto.Query
  require DogStatsd
  require Logger
  alias Plug.Conn

  defmodule NoIDProvided, do:
    defexception message: "no ID provided"
  defmodule UserNotInDB, do:
    defexception message: "provided user id not found in database"

  def init([]), do: []

  def call(conn, _) do
    try do
      userid = get_session(conn, :repo_userid)
      if userid do
        user = Survey.Repo.get_by(Survey.User, id: userid)
      end
      
      if !userid || !user do
        hash = conn.params["user_id"] || get_session(conn, :lti_userid)
        if !hash, do: raise NoIDProvided

        user = Survey.Repo.get_by(Survey.User, hash: hash)
        if !user, do: raise UserNotInDB
      end

      log_unique(user.id)
      Logger.metadata([id: user.id])
      conn 
      |> put_session(:repo_userid, user.id)
      |> assign(:user, user)

    rescue 
      e in NoIDProvided -> 
        Logger.info "EnsureRegistered: " <> Exception.message(e)
        conn
        |> put_resp_header("content-type", "text/plain; charset=utf-8")
        |> send_resp(Plug.Conn.Status.code(:forbidden), 
        "User not registered")
        |> halt
      UserNotInDB -> register_user(conn)

      e -> raise e
    end
  end

  def register_user(conn) do
    # check if we are being called by survey, and can do a transparent redirect, otherwise
    # we need to show a page asking user to manually "redirect him/herself"
    if get_session(conn, :edx_userid) do
      conn 
      |> put_session(:ensure_registered_redirect, full_path(conn))
      |> ParamSession.redirect("/user/register")
      |> Conn.halt
    else
      conn
      |> put_resp_header("content-type", "text/html; charset=utf-8")
      |> send_resp(Plug.Conn.Status.code(:ok), 
      "<h1>Registration required</h1>
      You need to register, before accessing any of the external interactive services
      in this course. Please go to the Entry Survey in Week Zero. You can find Week Zero
      in the menu along the left side of the screen. Completing the survey is not required
      (although we highly encourage it), but the registration part before the survey is
      needed. <p> Please go to register, and then come back to this activity again.
      <p>Thank you, and apologies for the inconvenience!")
      |> Conn.halt
    end
  end

  def log_unique(id) do
    Logger.info("Verified user id #{id}")
    {:ok, statsd} = DogStatsd.new("localhost", 8125)
    DogStatsd.set(statsd, "unique.users", id)
  end
end
