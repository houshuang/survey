defmodule Survey.Grade do
  require Logger
  alias Plug.Conn
  alias Survey.Repo

  defmodule NoLTISession, do:
    defexception message: "the session has not stored any LTI callbak info"

  defmodule NoCacheMatch, do:
    defexception message: "the session ID did not match any database records"

  defmodule GradeOutsideRange, do:
    defexception message: "grade must be between 0 and 1"

  # gets user info and current grade callback info from session and database
  # initially stores info about user grade etc in database, then makes call
  # if call succeeds, stores success in database
  def submit_grade(conn, component, grade) do
    if is_atom(component), do: component = Atom.to_string(component)
    if is_integer(grade), do: grade = grade * 1.0
    if is_binary(grade), do: grade = String.to_integer(grade)
    if grade < 0.0 or grade > 1.0, do: raise GradeOutsideRange

    cache_id = Conn.get_session(conn, :lti_grade)
    if !cache_id, do: raise NoLTISession
    lti = Survey.Cache.get(cache_id)
    if !lti, do: raise NoCacheMatch

    # store in db before calling callback url
    user_id = Conn.get_session(conn, :repo_userid)
    dbentry = %Survey.UserGrade{
      user_id: user_id,
      component: component,
      grade: grade,
      submitted: false,
      cache_id: cache_id}
    |> Repo.insert
    
    case res = PlugLti.Grade.call(lti, grade) do
      :ok -> Repo.update(%{dbentry | submitted: true})
      {:error, message} -> Logger.warn(
        "Not able to submit grade, UserGrade id #{dbentry.id}, message: #{message}")
    end
    res
  end
end
