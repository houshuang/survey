defmodule Survey.SIG do
  use Survey.Web, :model
  alias Survey.SIG
  alias Survey.Repo

  schema "sigs" do
    field :name, :string
    has_many :users, Survey.User
  end

  def name(id) do
    Survey.Repo.get(Survey.SIG, id).name
  end
end
