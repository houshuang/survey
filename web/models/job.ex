defmodule Survey.Job do
  use Survey.Web, :model
  import Ecto.Query
  require Ecto.Query
  require Logger

  alias Survey.Repo
  alias Survey.Job

  @groups Application.get_env(:jobs, :groups)
  @default Application.get_env(:jobs, :default)

  schema "jobs" do
    field :group, :integer
    field :mfa, Survey.Term
    field :tries, :integer
    field :next_try, :integer
    field :checked_out, :integer
    field :checked_out_pid, Survey.Term
  end

  def get_job do
    job = Survey.Repo.transaction(fn ->
      time = seconds_now
      job = (from f in Job,
        where: (f.next_try < ^time or is_nil(f.next_try)) and
          is_nil(f.checked_out) and
          (f.tries < ^@default.max_tries or is_nil(f.tries)) and
          not is_nil(f.mfa),
          limit: 1) 
      |> Repo.one
      IO.inspect(job)
      if job do
        [m, f, a] = job.mfa
        {pid, ref} = Task.async(m, f, a)

        job = %{ job | checked_out: time,
          checked_out_pid: pid,
          tries: (job.tries || 0) + 1,
          next_try: time + 60 * 5}
        IO.inspect(job)
        job
        |> Repo.update!
      end
      job 
    end)

    if job do
      Task.await(job.checked_out_pid)
      Logger.info("Completed job")
      Repo.delete(job)
    else
      nil
    end
  end

  def prune_max_tries do
    (from f in Job,
    where: f.tries > ^@default.max_tries)
    |> Repo.delete_all
  end

  def prune_running do
    (from f in Job,
    where: f.checked_out > ^(seconds_now + @default.worker_maxtime))
    |> Repo.all
    |> Enum.map(&update_and_kill/1)
  end

  def update_and_kill(job) do
    tries = (job.tries || 0) + 1
    %{ job | tries: tries, checked_out_pid: nil, checked_out: nil } |> Repo.update!
    :erlang.exit(job.checked_out_pid, :kill)
  end
  
  def seconds_now do
    Timex.Time.to_secs(:erlang.now)
    |> Float.floor
    |> Kernel.trunc
    0
  end
end
