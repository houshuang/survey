defmodule Survey.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    if exists? table(:tags) do
      drop table(:tags)
    end
    create table(:tags) do
      add :tag, :string
      add :steam, :"text[]"
      add :grade, :"text[]"
    end

  end
end
