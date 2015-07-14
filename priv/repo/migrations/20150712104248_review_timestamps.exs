defmodule Survey.Repo.Migrations.ReviewTimestamps do
  use Ecto.Migration

  def change do
    alter table(:reviews) do
      add :inserted_at, :datetime
      add :updated_at, :datetime
    end
  end
end
