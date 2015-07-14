defmodule Survey.Prompt do
  use Survey.Web, :model
  import Ecto.Query
  require Ecto.Query
 
  schema "prompts" do
    field :name, :string
    field :definition, :string
    field :html, :string
    field :question_def, Survey.Term
    timestamps
  end

  def get(id) do
    Survey.Repo.get(Survey.Prompt, id)
  end

  
end
