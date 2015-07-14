defmodule Survey.Repo.Migrations.Designgroups3 do
  use Ecto.Migration

  def change do
    alter table(:designgroups) do
      add :inserted_at, :datetime
    end
  end
end
