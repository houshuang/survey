defmodule Survey.Repo.Migrations.WikiIndexChange do
  use Ecto.Migration

  def change do
    drop index(:cache, [:blob], unique: false)
    execute("create index on cache using hash(blob)")
  end
end
