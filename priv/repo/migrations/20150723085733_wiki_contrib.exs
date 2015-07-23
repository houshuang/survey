defmodule Survey.Repo.Migrations.WikiContrib do
  use Ecto.Migration

  def change do
    alter table(:designgroups) do
      add :wiki_contributors, :integer
      add :wiki_diff, :integer
    end
  end
end
