defmodule Survey.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "rooms:*", RoomChannel
  channel "admin", AdminChannel
  channel "brainstorm:*", BrainstormChannel
  channel "control", ControlChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false
  transport :longpoll, Phoenix.Transports.LongPoll, check_origin: false
end
