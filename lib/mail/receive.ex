defmodule Mail.Receive do
  require Logger
  def receive_message(from, to, data) do
    Logger.warn("Message received: " <> inspect([from, to, data], pretty: true))
    # %{ template | 
    #   to: ["shaklev@gmail.com"],
    #   html: html ,
    #   text: text}
    # |> Survey.Mailer.deliver
    
  end
end
