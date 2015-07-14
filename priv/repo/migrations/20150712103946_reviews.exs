defmodule Survey.Repo.Migrations.Reviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :user_id, :integer
      add :design_group_id, :integer
      add :review, :jsonb
      add :week, :integer
    end
  end
end
