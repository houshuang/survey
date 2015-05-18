defmodule Survey.Repo.Migrations.AddUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :hash, :text
      add :nick, :text
      add :tags, :"text[]"
      add :survey, :jsonb
    end
  end
end
