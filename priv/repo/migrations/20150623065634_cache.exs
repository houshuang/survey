defmodule Survey.Repo.Migrations.Cache do
  use Ecto.Migration

  def change do
    create table(:cache) do
      add :blob, :bytea
    end
  end
end
