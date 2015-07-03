defmodule EnsureLti do
  @moduledoc """
  Checks if LTI_id exists in session hash, otherwise runs LTI verification.
  """

  use Behaviour
  @behaviour Plug
  require Logger
  alias Plug.Conn

  def init([]), do: []

  def call(conn, _) do
    conn = if conn.params["oauth_signature"] || !Conn.get_session(conn, :lti_userid) do
      conn = PlugLti.call(conn, [])
      |> Conn.put_session(:lti_userid, conn.params["user_id"])
      |> Conn.put_session(:edx_userid, conn.params["lis_person_sourcedid"])
      |> Conn.put_session(:edx_email, conn.params["lis_person_contact_email_primary"])
      |> Conn.put_session(:admin, conn.params["roles"] == "Instructor")

      # check if this is a graded section, and if it is, store call-back information
      case PlugLti.Grade.get_call_info(conn) do
        {:ok, info} -> 
          cache = Survey.Cache.store(info)
          conn = Conn.put_session( conn, :lti_grade, cache)
          Logger.info("Storing grade callback info cache #{cache}")
        :missing -> conn
      end
      %{conn | method: "GET"}

    else
      conn
    end
    Logger.info("PlugLti session: #{Conn.get_session(conn, :lti_userid)}")
    conn
  end

end
