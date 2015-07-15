defmodule Survey.JobWorker do
  use GenServer
  alias Survey.Job
  require Logger

  @delay_proc 120 * 1000
  @delay_clean 300 * 1000

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
    job = Job.checkout(self)
    if job do
      {m, f, a} = job.mfa

      case apply(m, f, a) do
        :ok      -> Job.completed(job)
        {:ok, _} -> Job.completed(job)
        x        -> 
          Logger.warn("Job #{inspect([m, f, a])}: #{inspect(x)}")
          Job.failed(job)
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
