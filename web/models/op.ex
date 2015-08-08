defmodule Survey.Op do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Op
  import Ecto.Query
  require Ecto.Query

  schema "ops" do
    field :room, :integer
    field :op, Survey.Term
  end

  def get_all(room) do
    (from f in Survey.Op,
    where: f.room == ^room,
    select: [f.op])
    |> Repo.all
  end
end
