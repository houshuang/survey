defmodule Survey.Review do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Review
  require Logger
  import Ecto.Query
  alias Ecto.Query

  schema "reviews" do
    field :design_group_id, :integer
    field :review, Survey.JSON
    field :week, :integer
    belongs_to :user, Survey.User
    timestamps 
  end

  def get(id), do: Repo.get(Review, id)
end

