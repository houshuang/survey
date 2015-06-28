defmodule Survey.Reflection do
  use Survey.Web, :model
 
  schema "reflections" do
    field :response, Survey.JSON
    belongs_to :prompt, Survey.Prompt
    belongs_to :user, Survey.User
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
