defmodule Survey.Repo.Migrations.Reflections do
  use Ecto.Migration

  def change do
    create index(:reflections, [:user_id])
  end
end
