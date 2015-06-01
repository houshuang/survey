defmodule Survey.Repo.Migrations.AddInsertedAt do
  use Ecto.Migration

  def change do
    drop table(:users)
      create table(:users) do
      add :hash, :text
      add :nick, :text
      add :tags, :"text[]"
      add :survey, :jsonb
      add :inserted_at, :datetime
      add :updated_at, :datetime
    end
end
end
