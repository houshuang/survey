defmodule Logger.Backends.ErrorMail do
  require Logger
  use GenEvent

  def init(_) do
   if user = Process.whereis(:user) do
      Process.group_leader(self(), user)
      Logger.info("Started")
      {:ok, configure([])}
    else
      {:ok, configure([])}
    end
  end

  def handle_call({:configure, options}, _state) do
    {:ok, :ok, configure(options)}
  end

  def handle_event({:error, _gl, {_, msg, ts, md}}, state) do
    log_event(msg, ts, md, state)
    {:ok, state}
  end

  # catchall
  def handle_event(event, state) do
    {:ok, state}
  end

  defp log_event(msg, ts, md, {from, to_list, format, metadata}) do
    msg = Logger.Formatter.format(format, :error, msg, ts, Dict.take(md, metadata))
          |> IO.iodata_to_binary
    if !String.contains?(inspect(msg), "GenServer :job_worker") do
      %Mailman.Email{
        from: from,
        to: to_list,
        text: msg}
      |> Survey.Mailer.deliver
    end
  end

  defp configure(options) do
    error_mail = Keyword.merge(Application.get_env(:logger, :error_mail, []), options)
    Application.put_env(:logger, :error_mail, error_mail)

    to_list  = Keyword.get(error_mail, :to_list)
    from     = Keyword.get(error_mail, :from)
    metadata = Keyword.get(error_mail, :metadata, [])

    format = Logger.Formatter.compile(Keyword.get(error_mail, :format))
    {from, to_list, format, metadata}
  end
end
