defmodule Survey.SIG do
  use Survey.Web, :model
  alias Survey.SIG
  alias Survey.Repo
  import Ecto.Query
  require Ecto.Query

  schema "sigs" do
    field :name, :string
    has_many :users, Survey.User
  end

  def name(id) do
    Survey.Repo.get(Survey.SIG, id).name
  end

  def map do
    (from t in SIG,
    select: [t.id, t.name])
    |> Repo.all
    |> Enum.map(fn [k,v] -> {k, v} end)
    |> Enum.into(%{})
  end
end
