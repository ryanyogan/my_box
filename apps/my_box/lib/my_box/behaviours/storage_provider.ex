defmodule MyBox.Behaviours.StorageProvider do
  @moduledoc false

  @type path :: binary()
  @type content :: bitstring()
  @type reason :: atom()
  @type details :: map()

  @callback upload(path, content) ::
              {:ok, :uploaded}
              | {:error, reason}
              | {:error, reason, details}

  @callback download(path) ::
              {:ok, content}
              | {:error, reason}
              | {:error, reason, details}
end
