defmodule Survey.Reflection do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Reflection
  import Ecto.Query
  require Ecto.Query

  schema "reflections" do
    field :response, Survey.JSON
    belongs_to :prompt, Survey.Prompt
    belongs_to :user, Survey.User
    timestamps
  end

  def get(userid, promptid) when is_integer(userid) and is_integer(promptid) do
    (from t in Reflection,
    where: t.user_id == ^userid,
    where: t.prompt_id == ^promptid)
    |> Repo.one
  end

  def store(uid, pid, resp) when is_integer(uid) and is_integer(pid) do
    reflection = get(uid, pid)
    
    if !reflection do
      reflection = %Reflection{user_id: uid, prompt_id: pid, response: resp}
      |> Repo.insert!
    else
      reflection = %{ reflection | response: resp } |> Repo.update!
    end

    reflection
  end
end
