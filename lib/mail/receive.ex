defmodule Mail.Receive do
  require Logger
  def receive_message(from, to, data) do
    email = data
    |> Mailman.Email.parse!

    %{ email | to: ["shaklev@gmail.com"] }
    |> Survey.Mailer.deliver
  end
end
