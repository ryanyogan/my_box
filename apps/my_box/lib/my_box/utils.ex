defmodule MyBox.Utils do
  require Logger

  def measure(fun) do
    fun
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
    |> log_time()
  end

  def log_time(time) do
    Logger.debug("Took: #{time} seconds.")
  end

  def run_and_measue(fun), do: :timer.tc(fun)

  def generate_timestamp do
    DateTime.utc_now()
    |> DateTime.to_iso8601(:basic)
    |> String.split(".")
    |> hd
  end
end
