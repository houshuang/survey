defmodule Survey.Repo.Migrations.Jobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :group, :integer
      add :mfa, :bytea
      add :tries, :integer
      add :next_try, :integer
      add :checked_out, :integer
      add :checked_out_pid, :bytea
    end
    create index(:jobs, [:next_try])
  end
end
