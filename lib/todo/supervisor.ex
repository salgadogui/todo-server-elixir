defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      %{
        id: :process_registry,
        start: {Todo.ProcessRegistry, :start_link, []},
        type: :worker
      },
      %{
        id: :database,
        start: {Todo.Database, :start_link, []},
        type: :supervisor
      },
      %{
        id: :cache,
        start: {Todo.Cache, :start_link, []},
        type: :worker
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
