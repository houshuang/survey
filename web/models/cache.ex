defmodule Survey.Cache do
  use Survey.Web, :model
  alias Survey.Repo

  schema "cache" do
    field :blob, :binary
  end

  def store(term) do
    blob = :erlang.term_to_binary(term)
    case Repo.get_by(Survey.Cache, blob: blob) do
      %{id: id} -> id
      nil -> insert(blob)
    end
  end

  defp insert(blob) do
    %{id: id} = %Survey.Cache{blob: blob}  |> Repo.insert!
    id
  end

  def get(id) do
    case Repo.get(Survey.Cache, id) do
      %{blob: blob} -> :erlang.binary_to_term(blob)
      nil           -> nil
    end
  end
end
