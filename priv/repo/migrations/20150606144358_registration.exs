defmodule Survey.Repo.Migrations.Registration do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :text
      add :grade, :"text[]"
      add :role, :"text[]" 
      add :steam, :"text[]"
      add :yearsteaching, :smallint
    end
  end
end
