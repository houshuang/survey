defmodule Survey.Repo.Migrations.EdxEmailUid do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :edx_email, :text
      add :edx_userid, :text
    end
  end
end
