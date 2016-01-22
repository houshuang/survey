defmodule EnsureSIG do
  @moduledoc """
  A plug run before every regular page request, to ensure that the user has selected a SIG.
  Should be called after ensure_register, which fetches user information.
  """

  use Behaviour
  @behaviour Plug
  import Plug.Conn

  require Ecto.Query
  import Ecto.Query
  require Logger
  alias Plug.Conn

  def init([]), do: []

  def call(conn, _) do
    if !conn.assigns.user.sig_id || conn.assigns.user.sig_id == 0 do
      Logger.info("Redirecting to SIG selection page")
      conn 
      |> put_session(:ensure_sig_redirect, conn.request_path)
      |> ParamSession.redirect("/user/select_sig")
      |> Conn.halt
    else
      conn
    end
  end
end
