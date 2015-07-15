defmodule Survey.JobWorker do
  use GenServer
  alias Survey.Job
  require Logger

  @delay_proc 120 * 1000
  @delay_clean 600 * 1000

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: :job_worker)
    clean
    work
    {:ok, pid}
  end

  def work do
    GenServer.cast(:job_worker, :work)
  end
  
  def clean do
    GenServer.cast(:job_worker, :clean)
  end
  #----------------------------------------

  def init([]) do
    clean
    work
    {:ok, []}
  end

  def handle_cast(:work, []) do
    job = Job.checkout_job(self)
    if job do
      {m, f, a} = job.mfa

      case apply(m, f, a) do
        :ok      -> Job.completed_job(job)
        {:ok, _} -> Job.completed_job(job)
        _        -> Job.failed(job)
      end

      work
    else
      :erlang.send_after(@delay_proc, self, :timer)
    end
    {:noreply, []}
  end

  def handle_info(:timer, []) do
    work
    {:noreply, []}
  end

  def handle_cast(:clean, []) do
    send self, :clean
    {:noreply, []}
  end

  def handle_info(:clean, []) do
    Job.clean
    :erlang.send_after(@delay_clean, self, :clean)
    {:noreply, []}
  end
end 
