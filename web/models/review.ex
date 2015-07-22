defmodule Survey.Review do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Review
  require Logger
  import Ecto.Query
  alias Ecto.Query
  import Prelude

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
    select: [f.week, f.review])
    |> Repo.all
    |> Enum.group_by(fn x -> Enum.at(x, 0) end)
    |> Enum.map(fn {k, v} -> {k,
      v
      |> Enum.map(fn [_, rest] -> rest end)
      |> Enum.reduce(%{}, fn x, acc -> Map.merge(x, acc, fn
        _, v1, v2 when is_list(v2) -> [ v1 | v2 ]
        _, v1, v2 -> [v1, v2]
      end) end)
      |> Enum.map(fn
        {k, v} when is_list(v) -> {string_to_int_safe(k), v}
        {k, v} when is_binary(v) -> {string_to_int_safe(k), [v]}
      end)
      |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
  end

  def max_review do
    (from f in Review,
    select: max(f.week))
    |> Repo.one
  end
end

