defmodule Survey.Repo.Migrations.Chat do
  use Ecto.Migration

  def change do
    create table(:chat) do
      add :nick, :text
      add :user_id, :integer
      add :body, :text
      add :room, :integer
      add :inserted_at, :datetime
    end
    create index(:chat, [:room])
  end
end
