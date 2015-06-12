defmodule Survey.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :tag, :string
      add :steam, :"text[]"
      add :grade, :"text[]"
    end

  end
end
