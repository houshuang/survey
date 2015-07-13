defmodule Mail.Receive do
  require Logger
  def receive_message(from, to, data) do
    email = data
    |> Mailman.Email.parse!
    Logger.warn([inspect(self), inspect(email, pretty: true)])

    t = %{ email | to: ["shaklev@gmail.com"], from: "relay@mooc.encorelab.org" }
    |> Survey.Mailer.deliver
    {:ok, _} = Task.await(t)
  end
end
