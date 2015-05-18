defmodule Survey.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :hash, :text
      add :nick, :text
      add :tags, {:array, :text}

      timestamps
    end

  end
end
