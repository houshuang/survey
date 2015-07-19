defmodule Survey.Cache do
  use Survey.Web, :model
  alias Survey.Repo

  schema "cache" do
    field :blob, Survey.Term
  end

  def store(blob) do
    Repo.transaction(fn ->
      case Repo.get_by(Survey.Cache, blob: blob) do
        %{id: id} -> id
        nil -> insert(blob)
      end
    end)
  end

  defp insert(blob) do
    %{id: id} = %Survey.Cache{blob: blob}  |> Repo.insert!
    id
  end

  def get(id) do
    case Repo.get(Survey.Cache, id) do
      %{blob: blob} -> blob
      nil           -> nil
    end
  end
end
