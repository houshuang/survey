defmodule Survey.Repo.Migrations.UserDesigngrp do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :design_group_id, :integer
    end
    create index(:users, [:design_group_id])
    
  end
end
