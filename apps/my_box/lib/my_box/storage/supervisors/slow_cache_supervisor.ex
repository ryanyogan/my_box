defmodule MyBox.Storage.Supervisors.SlowCacheSupervisor do
  @behaviour MyBox.Behaviours.CacheSupervisor

  alias MyBox.Storage.Supervisors.CacheSupervisor, as: RealCache

  def put(id, content), do: RealCache.put(id, content)

  def get(id) do
    seconds_to_sleep =
      case Integer.parse(id) do
        {sleep_time, _} -> sleep_time
        _ -> 1
      end

    Process.sleep(seconds_to_sleep * 1_000)
    RealCache.get(id)
  end

  def put_or_refresh(_id, _content), do: :noop
  def refresh(_id), do: :noop
end
