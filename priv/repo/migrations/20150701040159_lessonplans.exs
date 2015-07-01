defmodule Survey.Repo.Migrations.Lessonplans do
  use Ecto.Migration

  def change do
    create table(:commentstreams) do
      add :resourcetype, :text
      add :identifier, :text
      add :comments, :"jsonb[]"
    end
    create index(:commentstreams, [:resourcetype, :identifier])
  end
end
