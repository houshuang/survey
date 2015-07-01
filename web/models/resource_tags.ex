defmodule Survey.ResourceTag do
  use Survey.Web, :model

  import Ecto.Query
  require Ecto.Query
  alias Survey.Repo
  alias Survey.ResourceTag

  schema "resource_tags" do
    field :name, :string
    field :sigs, {:array, :integer}
  end

  defp and_and(query, col, val) when is_list(val) and is_atom(col) do
    from p in query, where: fragment("? && ?", ^val, field(p, ^col))
  end

  defp only_tags(query) do
    from p in query, select: p.name
  end

  defp alphabetize(query) do
    from p in query, order_by: p.name
  end

  def get_tags(sig) when is_integer(sig) do
    from(t in ResourceTag) 
    |> and_and(:sigs, [sig]) 
    |> only_tags 
    |> alphabetize
    |> Repo.all
  end

  def update_tags(sig, tags) when is_integer sig and is_list tags do
    tags
    |> Enum.map(fn x -> x |> String.strip |> String.downcase end)
    |> Enum.each(fn x -> update_tag(sig, x) end)
  end

  defp update_tag(sig, tagstr) when is_integer sig and is_binary tagstr do
    if tag = Repo.get_by(ResourceTag, name: tagstr) do
      nsig = merge_lists(tag.sigs, [sig])
      ntag = %{tag | sigs: nsig} 
      if ntag != tag, do: Repo.update!(ntag)
    else
      %ResourceTag{name: tagstr, sigs: [sig]}
      |> Repo.insert!
    end
  end

  def merge_lists(x, y) when is_list(x) and is_list(y) do
    Set.union(Enum.into(x, HashSet.new), Enum.into(y, HashSet.new))
    |> Set.to_list
  end
end
