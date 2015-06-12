defmodule ParamSession do
  use Behaviour
  import Plug.Conn
  @behaviour Plug
  import Prelude
  require Logger

  alias Plug.Session.COOKIE
  @opts Plug.Session.COOKIE.init Application.get_all_env(:param_session) 

  def init(_) do
  end

  def call(conn, _) do
    if sessionenc = conn.params["session"] do
      sessionenc = sessionenc
      |> URI.decode_www_form
      |> Base.decode64!
      {_, session} = COOKIE.get(conn, sessionenc, @opts)
      Logger.info("Session: #{inspect(session, pretty: true)}")
    else
      session = %{}
    end

    conn
    |> Plug.Conn.put_private(:plug_session, session)
    |> Plug.Conn.put_private(:plug_session_fetch, :done)
  end

  def gen_cookie(conn) do
    if conn.private[:plug_session] do
      cookie = Plug.Session.COOKIE.put(conn, [], conn.private.plug_session, @opts)
      cookie
      |> Base.encode64
      |> URI.encode_www_form
    else
      :none
    end
  end

  def form_session(conn) do
    case gen_cookie(conn) do
      :none -> Phoenix.HTML.raw ""
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
    Phoenix.Controller.redirect(conn, opts)
  end
end
