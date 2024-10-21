defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Todo.Database, []},
      {Todo.Cache, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
