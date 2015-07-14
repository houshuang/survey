defmodule Survey.Repo.Migrations.Etherpad do
  use Ecto.Migration

  def change do
    create table(:etherpads) do
      add :week, :integer
      add :design_group_id, :integer
      add :hash, :string
    end
    create index(:etherpads, [:hash])
    create index(:etherpads, [:week, :design_group_id])
  end
end
