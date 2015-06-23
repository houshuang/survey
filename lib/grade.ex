defmodule Survey.Grade do
  alias Plug.Conn
  defmodule NoLTISession, do:
    defexception message: "the session has not stored any LTI callbak info"

  defmodule NoCacheMatch, do:
    defexception message: "the session ID did not match any database records"

  def submit_grade(conn, grade) do
    id = Conn.get_session(conn, :lti_grade)
    if !id, do: raise NoLTISession
    lti = Survey.Cache.get(id)
    if !lti, do: raise NoCacheMatch
    
    PlugLti.Grade.call(lti, grade)
  end
end
