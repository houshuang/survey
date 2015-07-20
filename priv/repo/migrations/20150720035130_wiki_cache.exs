defmodule Survey.Repo.Migrations.WikiCache do
  use Ecto.Migration

  def change do
    alter table(:designgroups) do
      add :wiki_cache_id, :integer
    end
  end
end
