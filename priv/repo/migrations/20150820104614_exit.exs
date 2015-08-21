defmodule Survey.Repo.Migrations.Exit do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :exitsurvey_state, :boolean
      add :exitsurvey, :jsonb
    end
  end
end
