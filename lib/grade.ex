defmodule Survey.Grade do
  require Logger
  alias Plug.Conn
  alias Survey.Repo
  require Ecto.Query
  import Ecto.Query

  defmodule NoLTISession, do:
  defexception message: "the session has not stored any LTI callback info"

  defmodule NoCacheMatch, do:
  defexception message: "the session ID did not match any database records"

  defmodule GradeOutsideRange, do:
  defexception message: "grade must be between 0 and 1"

  # gets user info and current grade callback info from session and database
  # initially stores info about user grade etc in database, then makes call
  # if call succeeds, stores success in database
  def submit_grade(conn, component, grade) do
    if Application.get_env(:grade, :dont_submit) do
      Logger.warn("Grade submission disabled in config")
      conn
    else
      if is_atom(component), do: component = Atom.to_string(component)
      if is_integer(grade), do: grade = grade * 1.0
      if is_binary(grade), do: {grade, _} = Float.parse(grade)
      if grade < 0.0 or grade > 1.0, do: raise GradeOutsideRange

      cache_id = Conn.get_session(conn, :lti_grade)
      if !cache_id, do: raise NoLTISession
      lti = Survey.Cache.get(cache_id)
      if !lti, do: raise NoCacheMatch

      # store in db before calling callback url
      user_id = Conn.get_session(conn, :repo_userid)
      dbentry = (from t in Survey.UserGrade,
      where:
      t.user_id == ^user_id and
      t.component == ^component and
      t.grade == ^grade and
      t.cache_id == ^cache_id)
      |> Repo.one

      if !dbentry do
        dbentry = %Survey.UserGrade{
          user_id: user_id,
          component: component,
          grade: grade,
          submitted: false,
          cache_id: cache_id}
        |> Repo.insert!
      end

      if !dbentry.submitted do
        case res = PlugLti.Grade.call(lti, grade) do
          :ok -> 
            Repo.update!(%{dbentry | submitted: true})
            Logger.info("Submitted grade for #{component}")
          {:error, message} -> Logger.warn(
            "Not able to submit grade, UserGrade id #{dbentry.id}, " <>
            "message: #{inspect(message)}")
        end
        res
      else
        Logger.info("Already submitted grade for #{user_id} in #{component}")
        :ok
      end
    end
  end

  def resubmit_all_grades(component \\ nil) do
    query = (from f in Survey.UserGrade,
    select: [f.cache_id, f.grade])
    if component do
      query = from f in query, where: f.component == ^component
    end
    query 
    |> Repo.all
    |> Enum.map(&simple_submit/1)
  end

  def resubmit_failing(component \\ nil) do
    query = (from f in Survey.UserGrade,
    where: f.submitted == false)
    if component do
      query = from f in query, where: f.component == ^component
    end
    query 
    |> Repo.all
    |> Enum.map(&simple_submit/1)
  end

  def simple_submit(usergrade) do
    case PlugLti.Grade.call(Survey.Cache.get(usergrade.cache_id), usergrade.grade) do
      :ok -> 
        Logger.info("Submitted grade for #{usergrade.cache_id}")
      {:error, message} -> Logger.warn(
        "Not able to submit grade, cache id #{usergrade.cache_id}, message: #{inspect(message)}")
    end
  end

end
