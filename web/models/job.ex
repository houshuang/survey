defmodule Survey.Job do
  use Survey.Web, :model
  import Ecto.Query
  require Ecto.Query
  require Logger

  alias Survey.Repo
  alias Survey.Job

  schema "jobs" do
    field :group, :integer
    field :mfa, Survey.Term
    field :tries, :integer
    field :next_try, :integer
    field :checked_out, :integer
    field :checked_out_pid, Survey.Term
  end

  def add(mfa, group \\ nil) do
    %Job{mfa: mfa, group: group} |> Repo.insert!
    Survey.JobWorker.work
  end

  # gets a job that is ready for execution, and marks it as checked out
  # with the pid of the calling process, returns nil if there are no
  # jobs ready
  def checkout(pid) do
    default = Application.get_env(:jobs, :default)
    {:ok, job} = Repo.transaction(fn ->
      time = seconds_now
      job = (from f in Job,
        where: (f.next_try < ^time or is_nil(f.next_try)) and
          is_nil(f.checked_out) and
          (f.tries < ^default.max_tries or is_nil(f.tries)) and
          not is_nil(f.mfa),
          limit: 1) 
      |> Repo.one
      if job do
        job = %{ job | checked_out: time,
          checked_out_pid: pid,
          tries: (job.tries || 0) + 1,
          next_try: time + default.wait_try_again }
        |> Repo.update!
      end
    end)
    job
  end

  def get(id) do
    Repo.get(Job, id)
  end

  def completed(job) do
    Logger.info("Completed job #{job.id}")
    Repo.delete!(job)
  end

  def failed(job) do
    %{ job | checked_out_pid: nil, checked_out: nil } 
    |> Repo.update!
  end

  def clean do
    prune_running
    prune_max_tries
  end

  def prune_max_tries do
    default = Application.get_env(:jobs, :default)
    (from f in Job,
      where: f.tries > ^default.max_tries)
    |> Repo.delete_all
  end

  def prune_running do
    default = Application.get_env(:jobs, :default)
    (from f in Job,
      where: f.checked_out < ^(seconds_now - default.worker_maxtime))
    |> Repo.all
    |> Enum.map(&update_and_kill/1)
  end

  def update_and_kill(job) do
    Logger.warn("Killing process for job: #{job.id}")
    tries = (job.tries || 0) + 1
      %{ job | tries: tries, checked_out_pid: nil, checked_out: nil } 
    |> Repo.update!
    :erlang.exit(job.checked_out_pid, :kill)
  end
  
  def seconds_now do
    Timex.Time.to_secs(:erlang.now)
    |> Float.floor
    |> Kernel.trunc
  end
end
