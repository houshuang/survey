defmodule Survey.Repo.Migrations.ResourceOldRate do
  use Ecto.Migration
  def change do
    alter table(:resources) do
      add :old_score, :"jsonb[]"
    end
  end
end
