defmodule Survey.JobWorker do
  use GenServer
  alias Survey.Job
  require Logger

  @delay_proc 30 * 1000
  @delay_clean 60 * 1000

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
    Logger.info("Checking for work")
    job = Job.checkout_job(self)
    if job do
      Logger.info(inspect(job))
      {m, f, a} = job.mfa
      apply(m, f, a)
      Job.completed_job(job)
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
    Logger.info("Cleaning")
    Job.clean
    :erlang.send_after(@delay_clean, self, :clean)
    {:noreply, []}
  end
end 
