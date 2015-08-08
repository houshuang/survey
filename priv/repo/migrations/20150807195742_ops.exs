defmodule Survey.Repo.Migrations.Ops do
  use Ecto.Migration

  def change do
    create table(:ops) do
      add :room, :integer
      add :op, :bytea
    end
  end
end
