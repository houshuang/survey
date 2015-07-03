defmodule Survey.DesignGroup do
  use Survey.Web, :model
  alias Survey.Repo
  import Ecto.Query
  require Ecto.Query
  alias Survey.DesignGroup

  schema "designgroups" do
    field :description, Survey.JSON
    field :title, :string
    belongs_to :sig, Survey.SIG
    belongs_to :user, Survey.User
    timestamps updated_at: false
  end

  def submitted_count(uid) do
    (from f in DesignGroup,
    select: count(f.id),
    where: f.user_id == ^uid)
    |> Repo.one
  end
end

