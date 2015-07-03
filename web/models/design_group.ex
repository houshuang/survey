defmodule Survey.DesignGroup do
  use Survey.Web, :model
  alias Survey.Repo

  schema "designgroups" do
    field :description, Survey.JSON
    field :title, :string
    belongs_to :sig, Survey.SIG
  end
end

