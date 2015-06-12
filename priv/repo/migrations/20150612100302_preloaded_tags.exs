defmodule Survey.Repo.Migrations.PreloadedTags do
  use Ecto.Migration

  def up do
    tags = Poison.decode!(File.read!("data/tags.json"))
    Enum.each(tags, fn {grade, struct} -> proc_grade(grade, struct) end)
  end

  def down do
    
  end

  def proc_grade(grade, struct) do
    Enum.each(struct, fn {steam, list} -> Survey.Tag.update_tags([ grade ], [ steam ], list) end)
  end
end
