defmodule Survey.UserGrade do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.UserGrade
  require Ecto.Query
  import Ecto.Query

  schema "user_grades" do
    field :component, :string
    field :grade, :float
    field :submitted, :boolean
    belongs_to :user, Survey.User
    belongs_to :cache, Survey.Cache
  end

  def get(id) do
    (from f in UserGrade,
    where: f.user_id == ^id,
    select: [f.component, f.grade])
    |> Repo.all
  end
end
