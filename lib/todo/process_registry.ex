defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]

  use GenServer

  def init(_) do
    {:ok, Map.new()}
  end

  def send(key, message) do
    {_, response, _} = GenServer.call(self(), {:whereis_name, key})

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
    {:noreply, Map.pop(process_registry, pid, :not_found)}
  end
end
