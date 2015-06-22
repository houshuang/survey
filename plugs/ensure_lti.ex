defmodule EnsureLti do
  @moduledoc """
  Checks if LTI_id exists in session hash, otherwise runs LTI verification.
  """

  use Behaviour
  @behaviour Plug
  require Logger

  def init([]), do: []

  def call(conn, _) do
    conn = if conn.params["oauth_signature"] || !get_session(conn, :lti_userid) do
      conn = PlugLti.call(conn, [])
      |> put_session(:lti_userid, conn.params["user_id"])
      |> put_session(:edx_userid, conn.params["lis_person_sourcedid"])
      |> put_session(:edx_email, conn.params["lis_person_contact_email_primary"])
      |> put_session(:admin, conn.params["roles"] == "Instructor")

      # check if this is a graded section, and if it is, store call-back information
      case PlugLti.Grade.get_call_info do
        {:ok, info} -> store_call_info(info)
        :missing -> _
      end
      %{conn | method: "GET"}

    else
      conn
    end
    Logger.info("PlugLti session: #{get_session(conn, :lti_userid)}")
    conn
  end

  def store_call_info(info) do

  end
end
