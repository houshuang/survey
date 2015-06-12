defmodule Survey.User do
  use Survey.Web, :model

  schema "users" do
    field :hash, :string
    field :nick, :string
    field :edx_email, :string
    field :edx_userid, :string
    field :tags, {:array, :string}
    field :grade, {:array, :string}
    field :role, {:array, :string}
    field :steam, {:array, :string}
    field :survey, Survey.JSON
    field :yearsteaching, :integer
    field :surveystate, :integer
    field :allow_email, :boolean
    field :admin, :boolean
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
