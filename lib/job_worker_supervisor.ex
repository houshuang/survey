defmodule Survey.JobWorkerSupervisor do
use Supervisor

 def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Survey.JobWorker, [], restart: :permanent)
      worker(Survey.JobWorker, [], restart: :permanent)
      worker(Survey.JobWorker, [], restart: :permanent)
      worker(Survey.JobWorker, [], restart: :permanent)
      worker(Survey.JobWorker, [], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one, max_restarts: 5000, max_seconds: 5)
  end
end
