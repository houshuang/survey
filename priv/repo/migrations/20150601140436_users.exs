defmodule Survey.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :hash, :text
      add :nick, :text
      add :tags, :"text[]"
      add :survey, :jsonb
    end
  end
end

