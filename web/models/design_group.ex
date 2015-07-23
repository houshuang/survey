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
    field :wiki_url, :string
    field :wiki_cache_id, :integer
    field :wiki_rev, :integer
    belongs_to :sig, Survey.SIG
    belongs_to :user, Survey.User
    timestamps updated_at: false
  end

  def get_all_active do
    (from f in User,
    select: fragment("distinct(?)", f.design_group_id),
    where: not is_nil(f.design_group_id))
    |> Repo.all
  end

  def get_all_active_full do
    runq("
    WITH usercount AS (SELECT count(id) AS count, design_group_id AS gid FROM users WHERE design_group_id IS NOT NULL GROUP BY design_group_id) SELECT d.id, d.title, d.sig_id, d.wiki_url, u.count FROM designgroups d INNER JOIN usercount u ON d.id = u.gid;")
  end

  def get_emails(id) do
    (from f in User,
    where: f.design_group_id == ^id
    and ((is_nil(f.unsubscribe) or
    fragment("not ? && ?", f.unsubscribe, ^["all", "collab"]))),
    select: [f.id, f.edx_email])
    |> Repo.all
  end

  def get_random_wiki(sig) do
    :random.seed(:os.timestamp)
    possible = (from f in DesignGroup,
    where: not is_nil(f.wiki_cache_id) and
    f.sig_id == ^sig,
    select: [f.id, f.wiki_cache_id])
    |> Repo.all
    if Enum.empty?(possible) do
      nil
    else
      [id, cache_id] = Enum.at(possible,
        :random.uniform(Enum.count(possible)) - 1)
      {get(id), Survey.Cache.get(cache_id)}
    end
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

  def get_by_sig(sigid) do
    (from f in DesignGroup,
    where: f.sig_id == ^sigid)
    |> Repo.all
  end

  def list(sig) do
    runq(
  "WITH usercount AS (SELECT count(id) AS count, design_group_id AS design FROM users WHERE design_group_id IS NOT NULL GROUP BY design_group_id) SELECT d.id, u.count, d.title, d.description, d.user_id FROM designgroups d LEFT JOIN usercount u ON d.id = u.design WHERE d.sig_id=$1 ORDER BY (CASE WHEN u.count>6 THEN -99 WHEN u.count IS NULL THEN 0 ELSE u.count end) desc;", [sig])
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


  def all_involved do
    runq(
    "(SELECT user_id AS id FROM designgroups) UNION (SELECT id FROM users WHERE design_group_id IS NOT null);")
    |> Enum.map(fn {x} -> x end)
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

  def get_all do
    runq(
  "WITH u AS (SELECT nick, design_group_id AS design, id FROM users WHERE design_group_id IS NOT NULL) SELECT d.sig_id, u.design, d.title, u.nick, u.id  FROM u FULL JOIN designgroups d ON d.id = u.design;")
  |> Enum.group_by(fn {sig, design, title, nick, id} -> sig end)
  |> Enum.map(fn {y, x} -> {y, Enum.group_by(x, fn {sig, design, title, nick, id} -> design end)} end)

  end

end

