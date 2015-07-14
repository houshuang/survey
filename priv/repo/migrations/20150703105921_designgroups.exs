defmodule Survey.Repo.Migrations.Designgroups do
  use Ecto.Migration

  def change do
    create table(:designgroups) do
      add :description, :jsonb
      add :title, :text
      add :sig_id, :integer
    end
    create index(:designgroups, [:sig_id])
  end
end
