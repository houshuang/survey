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
    field :score, :integer
    belongs_to :sig, Survey.SIG
    belongs_to :user, Survey.User
    timestamps
  end

  # returns ID of an entry with a given URL, or nil if it doesn't exist
  def find_url(url) do
    req = from t in Survey.Resource,
      where: t.url == ^url,
      select: t.id
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

  # returns the id of a random resource fit for a given user, and adds it
  # to that users "has seen" list
  def get_random(user) do
    :random.seed(:os.timestamp)

    seen = user.resources_seen || []

    available_ids = 
    (from f in Survey.Resource,
    where: not (f.id in ^seen),
    where: not (f.user_id == ^user.id),
    select: f.id)
    |> Repo.all

    if length(available_ids) == 0 do
      nil
    else
      selected = :random.uniform(length(available_ids)) - 1
      s_id = Enum.at(available_ids, selected)
      %{ user | resources_seen: [ s_id | seen ]} |> Repo.update

      s_id
    end
  end
end
