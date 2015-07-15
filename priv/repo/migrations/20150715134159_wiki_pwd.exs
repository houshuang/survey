defmodule Survey.Repo.Migrations.WikiPwd do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :wiki_pwd, :text
    end
  end
end
