defmodule Survey.Brainstorm do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Brainstorm
  import Ecto.Query
  require Ecto.Query

  schema "brainstorm" do
    field :room, :integer
    field :state, Survey.Term
    field :userstate, Survey.Term
  end

  def store(id, room, state, userstate) do
    %Brainstorm{id: id, room: room, state: state, userstate: userstate} |> Repo.update!
  end

  def get_or_create(room) do
    case Repo.get_by(Brainstorm, room: room) do
      nil -> %Brainstorm{room: room, state: %{}, userstate: %{}} |> Repo.insert!
      x   -> x
    end
  end
end

