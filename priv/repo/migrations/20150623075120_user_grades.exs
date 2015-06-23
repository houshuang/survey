defmodule Survey.Repo.Migrations.UserGrades do
  use Ecto.Migration

  def change do
    create table(:user_grades) do
      add :user_id, :integer
      add :component, :text
      add :grade, :float
      add :cache_id, :integer
      add :submitted, :boolean
    end
    create index(:user_grades, [:user_id])
  end
end
