defmodule Brainstorm do

  def get_state(room) do
    if :ets.member(:brainstorm, room) do
      { id, room, state, userstate } = Enum.at(:ets.lookup(:brainstorm, room), 0)
    else
      %{ id: id, state: state, userstate: userstate } = Survey.Brainstorm.get_or_create(room)
      :ets.insert(:brainstorm, { id, room, state, userstate })
    end
    { id, room, state, userstate }
  end

  def do_op(room, op) do
    { id, room, state, userstate } = get_state(room)
    case op do
      {:new_idea, idea_id, user_id, idea} ->
        nick = Survey.User.get_nick(user_id)
        state = Map.put(state, idea_id,
          %{ idea: idea, user_id: user_id, user_nick: nick, comments: [], score: 0 })
        userstate = Map.update(userstate, user_id, [idea_id], fn user ->
          [ idea_id | user ]
        end)

      {:new_comment, idea_id, user_id, comment} ->
        nick = Survey.User.get_nick(user_id)
        state = Map.update(state, idea_id, %{}, fn idea ->
          newcomment = %{user_id: user_id, user_nick: nick, comment: comment}
          %{ idea | comments: [ newcomment | idea.comments ] }
        end)

      {:vote, idea_id, user_id} ->
        if not idea_id in Map.get(userstate, user_id, []) do
          state = Map.update(state, idea_id, %{}, fn idea ->
            %{ idea | score: idea.score + 1 }
          end)
          userstate = Map.update(userstate, user_id, [idea_id], fn user ->
            [ idea_id | user ]
          end)
        end
    end

    :ets.insert(:brainstorm, { id, room, state, userstate })
    # broadcast changes
    Survey.Brainstorm.store(id, room, state, userstate)
  end
end
