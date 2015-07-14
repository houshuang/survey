defmodule Survey.Repo.Migrations.QuestionDef do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :question_def, :bytea
    end
  end
end
