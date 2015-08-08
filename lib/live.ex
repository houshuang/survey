defmodule Live do
  require Logger

  def get_state(room) do
    ops = Survey.Op.get_all(room)
  end

  def state(room) do
    { id, room, state, userstate } = get_state(room)
    state
  end

  def do_op(room, user_id, op) do
    Logger.info("#{user_id} is doing op #{inspect(op)} in room #{room}")
    { id, room, state, userstate } = get_state(room)
    case op do
      ["new_idea", idea] ->
        nick = Survey.User.get_nick(user_id)
        idea_id = if Enum.empty?(Map.keys(state)) do
          1
        else
          (state
          |> Map.keys
          |> Enum.max) + 1
        end
        state = Map.put(state, idea_id,
          %{ idea: idea, user_id: user_id, user_nick: nick, comments: [], score: 0 })
        userstate = Map.update(userstate, user_id, [idea_id], fn user ->
          [ idea_id | user ]
        end)

      ["new_comment", idea_id, comment] ->
        nick = Survey.User.get_nick(user_id)
        state = Map.update(state, idea_id, %{}, fn idea ->
          newcomment = %{user_id: user_id, user_nick: nick, comment: comment}
          %{ idea | comments: [ newcomment | idea.comments ] }
        end)

      ["vote", idea_id] ->
        if not idea_id in Map.get(userstate, user_id, []) do
          state = Map.update(state, idea_id, %{}, fn idea ->
            %{ idea | score: idea.score + 1 }
          end)
          userstate = Map.update(userstate, user_id, [idea_id], fn user ->
            [ idea_id | user ]
          end)
        end

      # ["user_entered", user_nick] ->
      #   put_in(state, [:users_online], %{user_nick, 1})
    end

    Survey.Brainstorm.store(id, room, state, userstate)
    state
  end
end
