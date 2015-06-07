defmodule Survey.Repo do
  use Ecto.Repo, otp_app: :survey
  def log({atom, cmd, params}) do
    before_time = :os.timestamp
 
    result = super({atom, cmd, params})
 
    after_time = :os.timestamp
    diff = :timer.now_diff after_time, before_time
    :ok = :exometer.update ~w(:my_awesome_app ecto query_exec_time)a, diff / 1_000
    :ok = :exometer.update ~w(:my_awesome_app ecto query_count)a, 1
 
    result
  end
  def log(atom), do: super(atom)
 
end
