defmodule Survey.Repo.Migrations.Brainstorm do
  use Ecto.Migration

  def change do
    create table(:brainstorm) do
      add :room, :integer
      add :state, :bytea
    end
    create index(:brainstorm, [:room])
  end
end
