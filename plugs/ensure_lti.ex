defmodule EnsureLti do
  @moduledoc """
  Checks if LTI_id exists in session hash, otherwise runs LTI verification.
  """

  use Behaviour
  @behaviour Plug
  import Plug.Conn

  require Logger

  def init([]), do: []

  def call(conn, _) do
    conn = if conn.params["oauth_signature"] || !get_session(conn, :lti_userid) do
      conn = PlugLti.call(conn, [])
      |> put_session(:lti_userid, conn.params["user_id"])
      |> put_session(:edx_userid, conn.params["lis_person_sourcedid"])
      |> put_session(:edx_email, conn.params["lis_person_contact_email_primary"])
      |> put_session(:admin, conn.params["roles"] == "Instructor")
      %{conn | method: "GET"}

    else
      conn
    end
    Logger.info("PlugLti session: #{get_session(conn, :lti_userid)}")
    conn
  end
end
