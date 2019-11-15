defmodule MyBox.Behaviours.CacheSupervisor do
  @type id :: binary()
  @type content :: binary()
  @type reason :: tuple()

  @callback put(id, content) ::
              {:ok, pid}
              | {:error, reason}

  @callback refresh(id) :: :ok | nil

  @callback put_or_refresh(id, content) ::
              {:ok, pid}
              | {:error, reason}
              | :ok
              | nil

  @callback get(id) :: content | nil
end
