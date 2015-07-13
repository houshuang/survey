defmodule Survey.Repo.Migrations.DropUniqueCache do
  use Ecto.Migration
  def change do
    drop index(:cache, [:blob], unique: true)
    create index(:cache, [:blob], unique: false)
  end
end
