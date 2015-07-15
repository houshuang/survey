defmodule Survey.Repo.Migrations.DgroupUrl do
  use Ecto.Migration

  def change do
    alter table(:designgroups) do
      add :wiki_url, :text
    end
  end
end
