defmodule Survey.Commentstream do
  use Survey.Web, :model
  alias Survey.Repo
  alias Survey.Commentstream
  import Ecto.Query
  require Ecto.Query

  schema "commentstreams" do
    field :resourcetype, :string
    field :identifier, :string
    field :comments, {:array, Survey.JSON}
  end

  # retrieve a commentstream for a given rtype/id
  def get(rtype, id) when is_binary(rtype) and is_binary(id) do
    resource = (from t in Commentstream,
    where: t.identifier == ^id,
    where: t.resourcetype == ^rtype)
    |> Repo.one

    if !resource do
      resource = %Commentstream{resourcetype: rtype, identifier: id, comments: []} |> Repo.insert!
    end
    resource
  end

  def add(rtype, id, comment, userid, nick) 
    when is_binary rtype and is_binary(id) and is_binary(comment) and is_integer(userid) and is_binary(nick) do

    resource = get(rtype, id)
    if !resource do
      resource = %Commentstream{resourcetype: rtype, identifier: id, comments: []} |> Repo.insert!
    end

    newcomments = %{userid: userid, nick: nick, text: comment, date: Ecto.DateTime.local}
    comments = [ newcomments | resource.comments ]

    %{ resource | comments: comments } |> Repo.update!
    
  end
end
