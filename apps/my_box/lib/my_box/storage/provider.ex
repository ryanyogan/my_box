defmodule MyBox.Storage.Provider do
  @moduledoc """
  The Provider module is a function delegator based upon the
  behaviours defined for upload/2 and download/1

  Based upon the environment running, or provider you have given
  in the :storage_provider atom, this module will act as the public
  API for.
  """

  @target Application.get_env(:my_box, :storage_providers)

  defdelegate upload(path, content), to: @target
  defdelegate download(path), to: @target
end
