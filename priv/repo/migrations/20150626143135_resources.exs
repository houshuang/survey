defmodule Survey.Repo.Migrations.Resources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :name, :text
      add :url, :text
      add :tags, :"text[]"
      add :description, :text
      add :generic, :boolean
      add :user_id, :integer
      add :comments, :"jsonb[]"
      add :score, :float
      add :sig_id, :integer
      add :inserted_at, :datetime
      add :updated_at, :datetime
    end
    create index(:resources, [:url])
    create index(:resources, [:user_id])
    create index(:resources, [:tags])
    create index(:resources, [:score])

    alter table(:users) do
      add :resources_seen, :"integer[]"
    end
  end
end
