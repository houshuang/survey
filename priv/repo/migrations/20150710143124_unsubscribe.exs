defmodule Survey.Repo.Migrations.Unsubscribe do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :unsubscribe, :"text[]"
    end
  end
end
