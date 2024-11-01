defmodule Todo.Cache do
  use Supervisor

  def start_link do
    IO.puts("Starting the to-do cache")
    Supervisor.start_link(__MODULE__, nil, name: :todo_cache)
  end

  @impl true
  def init(_init_arg) do
    children = [
      %{
        id: Todo.ServerSupervisor,
        start: {Todo.ServerSupervisor, :start_link, []},
        type: :supervisor
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def server_process(todo_list_name) do
    Todo.ServerSupervisor.start_child(todo_list_name)
  end
end
