defmodule Todo.PoolSupervisor do
  use Supervisor

  def start_link(db_folder, pool_size) do
    Supervisor.start_link(__MODULE__, {db_folder, pool_size})
  end

  @impl Supervisor
  def init({db_folder, pool_size}) do
    children =
      for worker_id <- 1..pool_size do
        %{
          id: {:database_worker, worker_id},
          start: {Todo.DatabaseWorker, :start_link, [db_folder, worker_id]},
          restart: :permanent,
          shutdown: 5000,
          type: :worker
        }
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
