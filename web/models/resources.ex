defmodule Survey.Resource do
  use Survey.Web, :model
  alias Survey.Repo
  import Ecto.Query
  require Ecto.Query
 
  schema "resources" do
    field :name, :string
    field :url, :string
    field :tags, {:array, :string}
    field :description, :string
    field :generic, :boolean
    field :comments, {:array, Survey.JSON}
    field :old_desc, {:array, Survey.JSON}
    field :old_tags, {:array, Survey.JSON}
    field :score, :float
    field :old_score, {:array, Survey.JSON}
    belongs_to :sig, Survey.SIG
    belongs_to :user, Survey.User
    timestamps
  end

  # returns ID of an entry with a given URL, or nil if it doesn't exist
  def find_url(url, sig \\ nil) do
    req = from t in Survey.Resource,
      where: t.url == ^url,
      select: t.id,
      limit: 1
    if sig do
      req = from t in req, where: t.sig_id == ^sig
    end
    req |> Repo.one
  end

  def get_resource(id) do
    (from t in Survey.Resource,
    where: t.id == ^id,
    join: u in assoc(t, :user),
    preload: [user: u])
    |> Repo.one
  end

  # how many resources submitted by user
  def user_submitted_no(userid) do
    req = from t in Survey.Resource,
      where: t.user_id == ^userid,
      select: count(t.id)
    req |> Repo.one
  end

  # how many resources reviewed by user
  def user_reviewed_no(userid) do
    req = from t in Survey.User,
      where: t.id == ^userid,
      select: fragment("cardinality(?)", [t.resources_seen])
    req |> Repo.one
  end

  def get_all_by_sigs do
    (from t in Survey.Resource,
    join: s in assoc(t, :sig),
    join: u in assoc(t, :user),
    preload: [sig: s, user: u])
    |> Repo.all
    |> Enum.group_by(fn x -> x.sig.name end)
  end

  def update_seen(user, id) do
    seen = user.resources_seen
    if !seen, do: seen = []
    if not id in seen do
      %{ user | resources_seen: [ id | seen ]} |> Repo.update!
    end
  end

  # returns the id of a random resource fit for a given user, and adds it
  # to that users "has seen" list
  def get_random(user) do
    :random.seed(:os.timestamp)

    seen = user.resources_seen || []

    available_ids = 
    (from f in Survey.Resource,
    where: not (f.id in ^seen),
    where: not (f.user_id == ^user.id),
    where: (f.sig_id == ^user.sig_id) or 
      (f.generic == true),
    select: f.id)
    |> Repo.all

    if length(available_ids) == 0 do
      nil
    else
      selected = :random.uniform(length(available_ids)) - 1
      s_id = Enum.at(available_ids, selected)
      update_seen(user, s_id)

      s_id
    end
  end
end
