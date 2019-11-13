defmodule MyBox.Repo do
  use Ecto.Repo,
    otp_app: :my_box,
    adapter: Ecto.Adapters.Postgres
end
