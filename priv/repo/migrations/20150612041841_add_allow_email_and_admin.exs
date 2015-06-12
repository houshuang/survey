defmodule Survey.Repo.Migrations.AddAllowEmailAndAdmin do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :allow_email, :boolean
      add :admin, :boolean
    end
  end
end
