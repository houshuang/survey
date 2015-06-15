defmodule VerifyAdmin do
  @moduledoc """
  Checks if LTI_id exists in session hash, otherwise runs LTI verification.
  """

  use Behaviour
  @behaviour Plug
  import Plug.Conn

  require Logger

  def init([]), do: []

  def call(conn, _) do
    if get_session(conn, :admin_verified) == true do
      conn
    else
      if conn.params["password"] == Application.get_env(:verify_admin, :password) do
        put_session(conn, :admin_verified, true)
      else
        conn |> Phoenix.Controller.html("Not authorized") |> halt
      end
    end
  end
end
