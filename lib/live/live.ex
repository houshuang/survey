defmodule Live do
  use StateSync

  def init do
    %{presence: HashSet.new, chats: [], brainstorm: %{ideas: %{}, user_voted: %{}}}
  end

  @path [:presence]
  defop "user:entered", do: Set.put(state, args.usernick)
  defop "user:left", do: Set.delete(state, args.usernick)

  @path [:chats]
  defop "new:msg", do: [ args | state ]

  @path [:brainstorm, :ideas]
  ast = quote do defop "brainstorm:newidea" do
    idea_id = if Enum.empty?(Map.keys(state)) do
      1
    else
      (state
      |> Map.keys
      |> Enum.max) + 1
    end
    state = Map.put(state, idea_id,
    %{ idea: args.idea, user_nick: args.usernick, comments: [], score: 0 })
    emit "brainstorm:vote", %{ userid: args.userid, idea_id: idea_id }
  end end
  IO.puts Macro.to_string(Macro.expand_once(ast, __ENV__))

  defop "brainstorm:newidea" do
    idea_id = if Enum.empty?(Map.keys(state)) do
      1
    else
      (state
      |> Map.keys
      |> Enum.max) + 1
    end
    Map.put(state, idea_id,
    %{ idea: args.idea, user_nick: args.usernick, comments: [], score: 0 })
    emit "brainstorm:vote", %{ userid: args.userid, idea_id: idea_id }
  end

  defop "brainstorm:new_comment" do
    Map.update(state, args.idea_id, %{}, fn idea ->
      newcomment = %{nick: args.usernick, comment: args.comment}
      %{ idea | comments: [ newcomment | idea.comments ] }
    end)
  end

  defop "brainstorm:vote" do
    Map.update(state, args.idea_id, %{}, fn idea ->
      %{ idea | score: idea.score + 1 }
    end)
  end

  @path [:brainstorm, :user_voted]
  defop "brainstorm:add_voted", do: Prelude.Map.append(state, args.idea_id, args.userid)
end

