defmodule Survey.Repo.Migrations.DgroupEth do
  use Ecto.Migration

  def change do
    alter table(:designgroups) do
      add :etherpad_rev, :bytea
    end
  end
end
