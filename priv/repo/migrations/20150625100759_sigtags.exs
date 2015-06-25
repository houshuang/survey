defmodule Survey.Repo.Migrations.Sigtags do
  use Ecto.Migration

  import Prelude
  def change do
  end

  def up do
    create table(:resource_tags) do
      add :name, :text
      add :sigs, :"integer[]"
    end
    create index(:resource_tags, [:sigs])

    File.stream!("data/sigtags.csv") 
    |> CSV.decode(separator: ?,)
    |> Enum.map(fn x -> process_tag(x) end)
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.each(fn {tag, sigs} -> 
      %Survey.ResourceTag{name: tag, sigs: sigs} |> Survey.Repo.insert
    end)
  end

  def down do
    drop table(:resource_tags)
  end

  def process_tag(x) do
    tag = Enum.at(x, 0)
    sigs = x
    |> List.delete_at(0)
    |> List.delete_at(0)
    |> List.delete_at(0)
    |> List.delete_at(0)
    |> Enum.reduce([], fn x, acc ->
      if x != "" do
        [ string_to_int_safe(x) | acc ]
      else
        acc
      end
    end)
    if !Enum.empty?(sigs), do: {tag, sigs}
  end
end
