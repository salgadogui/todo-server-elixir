defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, Map.new()}
  end

  def register_name(key, pid) do
    GenServer.call(__MODULE__, {:register_name, key, pid})
  end

  def whereis_name(key) do
    GenServer.call(__MODULE__, {:whereis_name, key})
  end

  def send(key, message) do
    response = whereis_name(key)

    case response do
      :undefined ->
        {:badarg, {key, message}}

      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def handle_call({:register_name, key, pid}, _from, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}

      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _from, process_registry) do
    {
      :reply,
      Map.get(process_registry, key, :undefined),
      process_registry
    }
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  defp deregister_pid(process_registry, pid) do
    process_registry
    |> Enum.find(fn {_key, registered_pid} -> registered_pid == pid end)
    |> case do
      {key, _pid} -> Map.delete(process_registry, key)
      nil -> process_registry
    end
  end
end
