defmodule Survey.Repo.Migrations.CacheInde do
  use Ecto.Migration

  def change do
    create index(:cache, [:blob], unique: true)
  end
end
