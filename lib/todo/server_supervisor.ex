defmodule Todo.ServerSupervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, nil, name: :todo_server_supervisor)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      :todo_server_supervisor,
      {Todo.Server, [todo_list_name]}
    )
  end
end
