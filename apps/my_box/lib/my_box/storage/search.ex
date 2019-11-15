defmodule MyBox.Storage.Search do
  alias MyBox.Storage.Supervisors.SlowCacheSupervisor, as: Cache

  @name __MODULE__
  def search_for(media_id, expression) do
    raw_content_lines =
      media_id
      |> Cache.get()
      |> IO.inspect()
      |> elem(1)
      |> String.split("\n")

    result =
      raw_content_lines
      |> Stream.with_index()
      |> Enum.reduce(
        [],
        fn {content, line}, accum ->
          case found?(expression, content) do
            nil -> accum
            _ -> accum ++ [{line + 1, content}]
          end
        end
      )

    {media_id, result}
  end

  def naive_search_for(media_ids, expression) when is_list(media_ids) do
    media_ids
    |> Enum.map(&search_for(&1, expression))
    |> Enum.into(%{})
  end

  def task_search_for(media_ids, expression, timeout \\ 10_000)
      when is_list(media_ids) do
    media_ids
    |> Enum.map(&Task.async(@name, :search_for, [&1, expression]))
    |> Enum.map(&Task.await(&1, timeout))
  end

  def task_stream_search_for(media_ids, expression, concurrency \\ 4, timeout \\ 10_000)
      when is_list(media_ids) do
    options = [max_concurrency: concurrency, timeout: timeout]

    media_ids
    |> Task.async_stream(__MODULE__, :search_for, [expression], options)
    |> Enum.map(&elem(&1, 1))
    |> Enum.into(%{})
  end

  def safe_task_steam_search_for(media_ids, expression, concurrency \\ 4, timeout \\ 10_000) do
    options = [max_concurrency: concurrency, timeout: timeout, on_timeout: :kill_task]

    media_ids
    |> Task.async_stream(__MODULE__, :search_for, [expression], options)
    |> Enum.map(&elem(&1, 1))
    |> Enum.reject(&(&1 == :timeout))
    |> Enum.into(%{})
  end

  def found?(expression, content) do
    regex = ~r/#{expression}/
    Regex.run(regex, content, return: :index)
  end
end
