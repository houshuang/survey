defmodule Survey.SIG do
  use Survey.Web, :model
 
  schema "sigs" do
    field :name, :string
    has_many :users, Survey.User
  end
end
