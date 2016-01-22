defmodule Survey.Endpoint do
  use Phoenix.Endpoint, otp_app: :survey

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.

  socket "/ws", Survey.UserSocket
  socket "/ws/websocket", Survey.UserSocket
  plug Plug.Static,
    at: "/", from: :survey, gzip: true,
    only: ~w(lessonplans css fonts fonts img images js favicon.ico robots.txt brainstorm live)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head


  plug Survey.Router
end
