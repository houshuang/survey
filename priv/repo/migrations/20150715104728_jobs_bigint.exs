defmodule Survey.Repo.Migrations.JobsBigint do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      remove :next_try
      remove :checked_out
      add :next_try, :bigint
      add :checked_out, :bigint
    end
  end
end
