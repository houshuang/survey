defmodule Mail.SMTPServer do
    require Logger
    @behaviour :gen_smtp_server_session

    def init(hostname, session_count, address, options) do
	if session_count > 40 do
	    Logger.warn('SMTP server connection limit exceeded')
	    {:stop, :normal, ['421 ', hostname, ' is too busy to accept mail right now']}
	else
	    banner = [hostname, ' ESMTP']
	    state = %{}
	    {:ok, banner, state}
	end
    end

    # possibility of rejecting based on _from_ address
    def handle_MAIL(from, state) do
	{:ok, state}
    end

    # possibility of rejecting based on _to_ address
    def handle_RCPT(to, state) do
	{:ok, state}
    end

    # getting the actual mail. all the relevant stuff is in data.
    def handle_DATA(from, to, data, state) do
	Mail.Receive.receive_message(from, to, data)
	{:ok, UUID.uuid5(:dns, "mooc.encorelab.org", :default), state}
    end

    # --------------------------------------------------------------------------------
    # less relevant stuff

    def handle_HELO(hostname, state), do: {:ok, state}

    def handle_EHLO(hostname, extensions, state) do
	my_extensions = [ {'STARTTLS', true} | extensions ]
	{:ok, my_extensions, state}
    end

    def handle_RSET(state), do: state

    def handle_VRFY(_, state) do
	{:error, '252 VRFY disabled by policy, just send some mail', state}
    end

    def handle_other(verb, _, state) do
	{['500 Error: command not recognized : \'', verb, '\''], state}
    end

    def handle_STARTTLS(state), do: state

    def handle_info(info, state), do: {:noreply, state}

    def code_change(_OldVsn, state, _Extra), do: {:ok, state}

    def terminate(reason, state), do: {:ok, reason, state}
end
