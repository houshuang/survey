defmodule Mail.SMTPServer do
    require Logger
    @behaviour :gen_smtp_server_session

    def init(hostname, session_count, address, options) do
	if session_count > 40 do
	    Logger.warn("SMTP server connection limit exceeded")
	    {:stop, :normal, ["421 ", hostname, " is too busy to accept mail right now"]}
	else
	    banner = [hostname, " ESMTP"]
	    state = %{}
	    {:ok, banner, state}
	end
    end

    def handle_HELO(hostname, state), do: {:ok, state}

    def handle_EHLO(hostname, extensions, state) do
	my_extensions = extensions ++ [{"AUTH", "PLAIN LOGIN CRAM-MD5"}, {"STARTTLS", true}]
	{:ok, my_extensions, state}
    end

    def handle_MAIL(from, state) do
	{:ok, state}
    end

    def handle_RCPT(to, state) do
	{:ok, state}
    end

    def handle_DATA(from, to, data, state) do
	Mail.Receive.receive_message(from, to, data)
	{:ok, "", state}
    end

    def handle_RSET(state), do: state

    def handle_VRFY(_, state) do
	{:error, "252 VRFY disabled by policy, just send some mail", state}
    end

    def handle_other(verb, _, state) do
	{["500 Error: command not recognized : '", verb, "'"], state}
    end

    def handle_STARTTLS(state), do: state

    def handle_info(info, state), do: {:noreply, state}

    def code_change(_OldVsn, state, _Extra), do: {:ok, state}

    def terminate(reason, state), do: {:ok, reason, state}
end
