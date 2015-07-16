defmodule Survey.Repo.Migrations.Emails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :design_group_id, :integer
      add :from_id, :integer
      add :subject, :text
      add :content, :text
      add :from_web, :boolean
      add :inserted_at, :datetime
    end
  end
end
