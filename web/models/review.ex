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

  def get_by_group(id) do
    (from f in Review,
    where: f.design_group_id == ^id,
    select: f.review)
    |> Repo.all
    |> Enum.reduce(%{}, fn x, acc -> Map.merge(x, acc, fn
      _, v1, v2 when is_list(v2) -> [ v1 | v2 ]
      _, v1, v2 -> [v1, v2]
    end) end)
    |> Enum.map(fn 
      {k, v} when is_list(v) -> {k, v}
      {k, v} when is_binary(v) -> {k, [v]}
    end)
    |> Enum.into(%{})
  end
end

