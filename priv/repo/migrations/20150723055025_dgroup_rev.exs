defmodule Survey.Repo.Migrations.DgroupRev do
  use Ecto.Migration

  def change do
    alter table(:designgroups) do
      add :wiki_rev, :integer
    end
  end
end
