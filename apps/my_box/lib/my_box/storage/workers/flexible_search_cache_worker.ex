defmodule MyBox.Storage.Workers.FlexibleSearchCacheWorker do
  @moduledoc false

  use GenServer
  require Logger

  @name __MODULE__
  @search_cache :search_cache
  @expiration_seconds 60

  def start_link(storage \\ :ets) do
    GenServer.start_link(@name, storage, name: @name)
  end

  def init(storage) do
    Logger.debug("Search Cache Worker started with: #{storage} behaviour.")

    search_cache =
      case storage do
        :ets ->
          :ets.new(@search_cache, [:named_table, :set, :protected])

        :dets ->
          {:ok, name} = :dets.open_file(@search_cache, type: :set)
          name
      end

    {:ok, {storage, search_cache}}
  end

  def cache_search_result(media_id, search_expression, result),
    do: GenServer.call(@name, {:cache_search_result, media_id, search_expression, result})

  def search_result_for(media_id, search_expression),
    do: GenServer.call(@name, {:search_result_for, media_id, search_expression})

  def all_search_results_for(media_id),
    do: GenServer.call(@name, {:all_search_results_for, media_id})

  def expired_search_results(expiration_seconds \\ @expiration_seconds),
    do: GenServer.call(@name, {:expired_search_results, expiration_seconds})

  defp expired_search_results_query(expiration_seconds) do
    expiration_time = :os.system_time(:seconds) - expiration_seconds

    [
      {
        {:"$1", {:"$2", :_}},
        [{:<, :"$2", {:const, expiration_time}}],
        [:"$1"]
      }
    ]
  end

  def delete_cache_search(media_id, search_expression),
    do: GenServer.call(@name, {:delete_cache_search, [{media_id, search_expression}]})

  def delete_cache_search(keys) when is_list(keys) and length(keys) > 0,
    do: GenServer.call(@name, {:delete_cache_search, keys})

  def handle_call({:delete_cache_search, keys}, _from, {storage, search_cache})
      when is_list(keys) do
    result =
      delete(keys, storage)
      |> Enum.reduce(true, fn r, acc -> r && acc end)

    {:reply, {:ok, result}, {storage, search_cache}}
  end

  def handle_call(
        {:search_result_for, media_id, search_expression},
        _from,
        {storage, search_cache}
      ) do
    result =
      case storage.lookup(search_cache, {media_id, search_expression}) do
        [] ->
          nil

        [{_key, {_created_at, search_result}}] ->
          search_result
      end

    {:reply, {:ok, result}, {storage, search_cache}}
  end

  def handle_call({:expired_search_results, expired_seconds}, _from, {storage, search_cache}) do
    query = expired_search_results_query(expired_seconds)

    {:reply, {:ok, storage.select(@search_cache, query)}, {storage, search_cache}}
  end

  def handle_call({:all_search_results_for, media_id}, _from, {storage, search_cache}) do
    results =
      case storage.match_object(@search_cache, {{media_id, :_}, :_}) do
        [] ->
          nil

        all_objects ->
          all_objects
          |> Enum.map(fn {key, value} ->
            {elem(key, 1), elem(value, 1)}
          end)
      end

    {:reply, {:ok, results}, {storage, search_cache}}
  end

  def handle_call(
        {:cache_search_result, media_id, search_expression, result},
        _from,
        {storage, search_cache}
      ) do
    created_at = :os.system_time(:seconds)

    result =
      storage.insert_new(search_cache, {{media_id, search_expression}, {created_at, result}})

    {:reply, {:ok, result}, {storage, search_cache}}
  end

  def terminate(_reason, {storage, search_cache}) do
    case storage do
      :dets ->
        storage.close(search_cache)

      _ ->
        :noop
    end
  end

  defp delete([], _storage), do: []
  defp delete([key | rest], storage), do: [delete(key, storage)] ++ delete(rest, storage)
  defp delete(key, storage), do: storage.delete(@search_cache, key)
end
