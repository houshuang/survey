defmodule ParamSession do
  use Behaviour
  import Plug.Conn
  @behaviour Plug
  import Prelude
  require Logger

  alias Plug.Session.COOKIE

  def init(_) do
    Plug.Session.COOKIE.init store: :cookie,
                         key: "session",
                         encryption_salt: "fkljsdfsdif-09sdf-9834j993920092090kjj",
                         signing_salt: "skljdfls9980982049834fsdfsdf900d",
                         key_length: 64
  end

  def call(conn, opts) do
    if sessionenc = conn.params["session"] do
      {_, session} = COOKIE.get(conn, sessionenc, opts)
    else
      session = %{}
    end

    Logger.warn("Session: #{inspect(session)}")

    conn
    |> Plug.Conn.put_private(:plug_session, session)
    |> Plug.Conn.put_private(:plug_session_fetch, :done)
  end

  def gen_cookie(conn) do
    opts = Plug.Session.COOKIE.init store: :cookie,
                         key: "session",
                         encryption_salt: "fkljsdfsdif-09sdf-9834j993920092090kjj",
                         signing_salt: "skljdfls9980982049834fsdfsdf900d",
                         key_length: 64

    if conn.private[:plug_session] do
      Plug.Session.COOKIE.put(conn, [], conn.private.plug_session, opts)
    else
      :none
    end
  end

  def form_session(conn) do
    case gen_cookie(conn) do
      :none -> ""
      x -> Phoenix.HTML.raw "<input name='session' type='hidden' value='#{x}'>"
    end
  end

  def url(conn, url) do
    url <> "?session=" <> gen_cookie(conn)
  end

  def redirect(conn, opts) do
    if to = opts[:to] do
      opts = [ {:to, url(conn, to) } | opts ]
    end
    Logger.warn(inspect(opts))
    Phoenix.Controller.redirect(conn, opts)
  end
end
