defmodule Survey.ChatPresence do
  def start_link do
    Agent.start_link(fn -> {HashDict.new, HashDict.new, HashDict.new} end, name: __MODULE__)
  end

  def get(room) do
    Agent.get(__MODULE__, fn {room_store, _, _} ->
      room_store[room]
    end)
  end

  def add_user(room, user, socket) do
    socket = socket.channel_pid
    Agent.update(__MODULE__, fn {room_store, user_store, lock_store} ->
    {Dict.update(room_store, room,
        Enum.into([user], HashSet.new),
        fn set -> Set.put(set, user) end),

      Dict.put(user_store, socket, {room, user}), lock_store}
    end)
  end

  def get_user(socket) do
    socket = socket.channel_pid
    Agent.get(__MODULE__, fn {_, user_store, lock_store} ->
      user_store[socket]
    end)
  end

  def remove_user(socket) do
    {room, user} = get_user(socket)
    socket = socket.channel_pid
    Agent.update(__MODULE__, fn {room_store, user_store, lock_store} ->
    {Dict.update(room_store, room,
      HashSet.new,
      fn set -> Set.delete(set, user) end),
    Dict.delete(user_store, socket), lock_store}
    end)
    {room, user}
  end

  def not_online?(room, user) do
    roomusers = get(room)
    if !roomusers do
      true
    else
      roomusers
      |> Enum.filter(fn %{"userid" => userid} -> userid == user end)
      |> Enum.empty?
    end
  end

  def get_all_users do
    Agent.get(__MODULE__, fn {room_store, _, lock_store} ->
      room_store
    end)
    |> Enum.map(fn {num, hset} -> Enum.to_list(hset) end)
    |> List.flatten
    |> Enum.map(fn %{"userid" => uid, "usernick" => nick} -> uid end)
  end

  def get_all_users_by_room do
    Agent.get(__MODULE__, fn {room_store, _, lock_store} ->
      room_store
    end)
    |> Enum.map(fn {num, hset} -> {num, Enum.map(hset, fn x -> x["userid"] end)} end)
    |> Enum.into(%{})
  end

  def lock(room, topic, socket, user) do
    socket = socket.channel_pid
    Agent.update(__MODULE__, fn {room_store, user_store, lock_store} ->
    {room_store, user_store,
      Dict.put(lock_store, socket, {room, topic, user})}
    end)
  end

  def get_locks(room) do
    Agent.get(__MODULE__, fn {room_store, user_store, lock_store} ->
      lock_store end)
    |> Enum.map(fn {k,v} -> v end)
    |> Enum.filter(fn {roomid, topic, user} -> roomid == room end)
  end

  def open(socket) do
    socket = socket.channel_pid
    Agent.update(__MODULE__, fn {room_store, user_store, lock_store} ->
    {room_store, user_store,
      Dict.delete(lock_store, socket)}
    end)
  end

  def close_locks(socket) do
    socket = socket.channel_pid
    Agent.get_and_update(__MODULE__, fn {room_store, user_store, lock_store} ->
    {lock_store[socket],
    {room_store, user_store,
      Dict.delete(lock_store, socket)}}
    end)
  end

  def dump do
    Agent.get(__MODULE__, fn x -> x end)
  end
end
