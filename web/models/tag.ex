defmodule Survey.Tag do
  use Survey.Web, :model

  schema "tags" do
    field :tag, :string
    field :steam, {:array, :string}
    field :grade, {:array, :string}
  end

  @required_fields ~w(tag)
  @optional_fields ~w()
  import Ecto.Query
  require Ecto.Query
  alias Survey.Repo
  alias Survey.Tag

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  defp and_and(query, col, val) when is_list(val) and is_atom(col) do
    from p in query, where: fragment("? && ?", ^val, field(p, ^col))
  end

  defp only_tags(query) do
    from p in query, select: p.tag
  end

  def get_tag(grade, steam) when is_list(grade) and is_list(steam) do
    from(t in Tag) 
    |> and_and(:grade, grade) 
    |> and_and(:steam, steam) 
    |> only_tags 
    |> Repo.all
  end

  def update_tags(grade, steam, tags) when is_list grade and is_list steam and is_list tags do
    tags 
    |> Enum.map(fn x -> x |> String.strip |> String.downcase end)
    |> Enum.each(fn x -> update_tag(grade, steam, x) end)
  end

  defp update_tag(grade, steam, tagstr) do
    if tag = Repo.get_by(Tag, tag: tagstr) do
      nsteam = merge_lists(tag.steam, steam)
      ngrade = merge_lists(tag.grade, grade)
      ntag = %{tag | steam: nsteam, grade: ngrade} 
      if ntag != tag, do: Repo.update(ntag)
    else
      %Tag{tag: tagstr, grade: grade, steam: steam}
      |> Repo.insert
    end
  end

  def merge_lists(x, y) when is_list(x) and is_list(y) do
    Set.union(Enum.into(x, HashSet.new), Enum.into(y, HashSet.new))
    |> Set.to_list
  end
end
