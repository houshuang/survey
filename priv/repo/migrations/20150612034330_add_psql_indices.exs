defmodule Survey.Repo.Migrations.AddPsqlIndices do
  use Ecto.Migration

  def change do
    create index(:users, [:hash], unique: true)
  end

  def up do
    execute "CREATE INDEX surveygin ON users USING gin (survey);"
  end

  def down do
    execute "DROP INDEX surveygin;"
  end
end
