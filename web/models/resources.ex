defmodule Survey.Resource do
  use Survey.Web, :model
 
  schema "resources" do
    field :name, :string
    field :url, :string
    field :tags, {:array, :string}
    field :description, :string
    field :generic, :boolean
    field :user_id, :integer
    field :comments, {:array, Survey.JSON}
    field :score, :integer
    belongs_to :sig, Survey.SIG
    timestamps
  end

  # defp and_and(query, col, val) when is_list(val) and is_atom(col) do
  #   from p in query, where: fragment("? && ?", ^val, field(p, ^col))
  # end

  # defp only_tags(query) do
  #   from p in query, select: p.tag
  # end

  # def get_tags(grade, steam) when is_list(grade) and is_list(steam) do
  #   from(t in Tag) 
  #   |> and_and(:grade, grade) 
  #   |> and_and(:steam, steam) 
  #   |> only_tags 
  #   |> Repo.all
  # end

  # def update_tags(grade, steam, tags) when is_list grade and is_list steam and is_list tags do
  #   tags 
  #   |> Enum.map(fn x -> x |> String.strip |> String.downcase end)
  #   |> Enum.each(fn x -> update_tag(grade, steam, x) end)
  # end

  # defp update_tag(grade, steam, tagstr) do
  #   if tag = Repo.get_by(Tag, tag: tagstr) do
  #     nsteam = merge_lists(tag.steam, steam)
  #     ngrade = merge_lists(tag.grade, grade)
  #     ntag = %{tag | steam: nsteam, grade: ngrade} 
  #     if ntag != tag, do: Repo.update(ntag)
  #   else
  #     %Tag{tag: tagstr, grade: grade, steam: steam}
  #     |> Repo.insert
  #   end
  # end

  # def merge_lists(x, y) when is_list(x) and is_list(y) do
  #   Set.union(Enum.into(x, HashSet.new), Enum.into(y, HashSet.new))
  #   |> Set.to_list
  # end
end
