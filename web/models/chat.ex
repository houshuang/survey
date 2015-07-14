defmodule Survey.Chat do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Chat
  require Logger
  import Ecto.Query
  alias Ecto.Query

  schema "chat" do
    field :nick, :string
    field :body, :string
    field :room, :integer
    belongs_to :user, Survey.User
    timestamps updated_at: false
  end

  def insert(obj, room) do
    %Chat{nick: obj["user"], body: obj["body"], room: room} |> Repo.insert! 
  end

  def get(room, limit \\ 10) do
    query = (from t in Chat,
    where: t.room == ^room,
    order_by: [desc: t.inserted_at],
    select: [t.nick, t.body, t.inserted_at])
    if limit do
      query = from t in query, limit: ^limit
    end
    query 
    |> Repo.all
    |> Enum.reverse
    |> Enum.map(fn [user, body, date] -> %{
      user: user, 
      body: body, 
      time: Ecto.DateTime.to_string(date)} 
    end)
  end

  def get_each do
    query = (from t in Chat,
    order_by: [asc: t.inserted_at],
    select: [t.room, t.nick, t.body, t.inserted_at])
    |> Repo.all
    |> Enum.map(fn [room, user, body, date] -> %{
      room: room,
      user: user, 
      body: body, 
      time: Ecto.DateTime.to_string(date)} 
    end)
    |> Enum.group_by(fn x -> x.room end)
    |> Enum.map(fn {id, list} -> Enum.take(list, 3) end)
    |> List.flatten
  end
end
