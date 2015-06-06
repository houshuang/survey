defmodule Survey.Repo.Migrations.Surveycomplete do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :surveystate, :smallint
    end
  end
end
