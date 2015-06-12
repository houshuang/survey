defmodule Survey.Repo.Migrations.TagsTable do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :steam, :"text[]"
      add :grade, :"text[]"
      add :tag, :text
    end
    create index(:tags, [:tag], unique: true)
    create index(:tags, [:steam, :grade])
  end
end
