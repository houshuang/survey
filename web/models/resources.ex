defmodule Survey.Resource do
  use Survey.Web, :model
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
    req |> Survey.Repo.one
  end

  def get_all_by_sigs do
    (from t in Survey.Resource,
    join: s in assoc(t, :sig),
    join: u in assoc(t, :user),
    preload: [sig: s, user: u])
    |> Survey.Repo.all
    |> Enum.group_by(fn x -> x.sig.name end)
  end
end
