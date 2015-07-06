defmodule Survey.DesignGroup do
  use Survey.Web, :model
  alias Survey.Repo
  import Ecto.Query
  require Ecto.Query
  alias Survey.DesignGroup
  alias Survey.User
  alias Ecto.Adapters.SQL
  require Logger

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

  def get(id) do
    Repo.get(DesignGroup, id)
  end

  def list(sig) do
    runq(
  "WITH usercount AS (SELECT count(id) AS count, design_group_id AS design FROM users WHERE design_group_id IS NOT NULL GROUP BY design_group_id) SELECT d.id, u.count, d.title, d.description FROM designgroups d LEFT JOIN usercount u ON d.id = u.design WHERE d.sig_id=$1 ORDER BY (CASE WHEN u.count>6 THEN -99 WHEN u.count IS NULL THEN 0 ELSE u.count end) desc;", [sig])
  end

  def runq(query, opts \\ []) do
    result = SQL.query(Survey.Repo, query, opts)
    result.rows
  end

  def get_by_user(id) when is_integer(id) do
    req = (from f in User,
    where: f.id == ^id,
    preload: [:design_group])
    |> Repo.one
  end

  def insert_once(struct) do
    req = (from f in DesignGroup,
    where: f.user_id == ^struct.user_id,
    where: f.title == ^struct.title)
    |> Repo.all

    if !Enum.empty?(req) do
      :already
      Logger.info("Already saved this resource")
    else
      struct |> Repo.insert!
      :success
    end
  end

  def get_members(id) do
    req = (from f in User,
    where: f.design_group_id == ^id,
    select: [f.id, f.nick])
    |> Repo.all
  end
end

