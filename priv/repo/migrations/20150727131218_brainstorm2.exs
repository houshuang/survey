defmodule Survey.Repo.Migrations.Brainstorm2 do
  use Ecto.Migration

  def change do
    alter table(:brainstorm) do
      add :userstate, :bytea
    end
  end
end
