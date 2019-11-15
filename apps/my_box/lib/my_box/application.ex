defmodule MyBox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias MyBox.Storage.Supervisors.CacheSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link(
      [
        supervisor(MyBox.Repo, []),
        supervisor(CacheSupervisor, [], name: CacheSupervisor)
      ],
      strategy: :one_for_one,
      name: MyBox.Supervisor
    )
  end
end
