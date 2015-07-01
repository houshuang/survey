defmodule Survey.Repo.Migrations.ResourceOld do
  use Ecto.Migration
  def change do
    alter table(:resources) do
      add :old_desc, :"jsonb[]"
    end
  end
end
