defmodule Survey.Repo.Migrations.Sigs do
  use Ecto.Migration

  def change do
    create table(:sigs) do
      add :name, :text
    end

    alter table(:users) do
      add :sig_id, :integer
    end
  end
end
