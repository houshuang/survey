defmodule Survey.Repo.Migrations.ResourceOldTags do
  use Ecto.Migration
  def change do
    alter table(:resources) do
      add :old_tags, :"jsonb[]"
    end
  end
end
