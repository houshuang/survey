defmodule Survey.Repo.Migrations.Designgroups2 do
  use Ecto.Migration

  def change do
    alter table(:designgroups) do
      add :user_id, :integer
    end
    create index(:designgroups, [:user_id])
  end
end
