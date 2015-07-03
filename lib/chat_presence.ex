defmodule Survey.ChatPresence do
  def start_link do
    Agent.start_link(fn -> {HashDict.new, HashDict.new} end, name: __MODULE__)
  end

  def get(room) do
    Agent.get(__MODULE__, fn {room_store, _} -> 
      room_store[room]
    end)
  end

  def add_user(room, user, socket) do
    socket = socket.channel_pid
    Agent.update(__MODULE__, fn {room_store, user_store} -> 
    {Dict.update(room_store, room, 
        Enum.into([user], HashSet.new),
        fn set -> Set.put(set, user) end),

      Dict.put(user_store, socket, {room, user})}
    end)
  end

  def get_user(socket) do
    socket = socket.channel_pid
    Agent.get(__MODULE__, fn {_, user_store} -> 
      user_store[socket]
    end)
  end

  def remove_user(socket) do
    {room, user} = get_user(socket)
    socket = socket.channel_pid
    Agent.update(__MODULE__, fn {room_store, user_store} -> 
    {Dict.update(room_store, room, 
      HashSet.new,
      fn set -> Set.delete(set, user) end), 
    Dict.delete(user_store, socket)}
    end)
    user
  end

  def dump do
    Agent.get(__MODULE__, fn x -> x end)
  end
end
