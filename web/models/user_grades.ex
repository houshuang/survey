defmodule Survey.UserGrade do
  use Survey.Web, :model
  alias Survey.Repo

  schema "user_grades" do
    field :component, :string
    field :grade, :float
    field :submitted, :boolean
    belongs_to :user, Survey.User
    belongs_to :cache, Survey.Cache
  end
end
