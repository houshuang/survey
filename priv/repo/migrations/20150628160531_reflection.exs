defmodule Survey.Repo.Migrations.Reflection do
  use Ecto.Migration

  def change do
    create table(:reflections) do
      add :response, :jsonb
      add :prompt_id, :integer
      add :user_id, :integer
      add :inserted_at, :datetime
      add :updated_at, :datetime
    end
    create index(:reflections, [:prompt_id])

    create table(:prompts) do
      add :name, :text
      add :definition, :text
      add :html, :text
      add :inserted_at, :datetime
      add :updated_at, :datetime
    end
  end
end
