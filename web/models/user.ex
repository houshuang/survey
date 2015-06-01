defmodule Survey.User do
  use Survey.Web, :model

  schema "users" do
    field :hash, :string
    field :nick, :string
    field :tags, {:array, :string}
    field :survey, Survey.JSON
    timestamps
  end

  @required_fields ~w(hash nick)
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
