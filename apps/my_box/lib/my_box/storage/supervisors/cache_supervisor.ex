defmodule MyBox.Storage.Supervisors.CacheSupervisor do
  @behaviour MyBox.Behaviours.CacheSupervisor

  use DynamicSupervisor
  alias MyBox.Storage.Workers.CacheWorker

  @name __MODULE__

  def start_link() do
    DynamicSupervisor.start_link(@name, [], name: @name)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def put(id, content) when is_binary(id) and is_bitstring(content) do
    DynamicSupervisor.start_child(
      @name,
      cache_worker_spec(id, content)
    )
  end

  def refresh(id) when is_binary(id) do
    case find_cache(id) do
      nil -> nil
      pid -> CacheWorker.refresh(pid)
    end
  end

  def put_or_refresh(id, content) when is_binary(id) and is_bitstring(content) do
    case refresh(id) do
      nil -> put(id, content)
      result -> result
    end
  end

  def get(id) when is_binary(id) do
    case find_cache(id) do
      nil -> nil
      pid -> CacheWorker.get_media(pid)
    end
  end

  def find_cache(id) when is_binary(id) do
    GenServer.whereis(CacheWorker.name_for(id))
  end

  defp cache_worker_spec(id, content) do
    Supervisor.child_spec(
      CacheWorker,
      start: {CacheWorker, :start_link, [id, content]},
      restart: :temporary
    )
  end
end
