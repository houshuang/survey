defmodule Survey.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "rooms:*", RoomChannel
  channel "admin", AdminChannel
  channel "brainstorm:*", BrainstormChannel
  channel "control", ControlChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll
end
