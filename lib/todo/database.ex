defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @pool_size 3

  def start_link(db_folder) do
    Todo.PoolSupervisor.start_link(db_folder, @pool_size)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end

  defp start_workers() do
    for index <- 1..3, into: %{} do
      IO.puts("Starting database worker #{index}")
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder, index)
      {index - 1, pid}
    end
  end
end
