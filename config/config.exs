# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :my_box_web,
  ecto_repos: [MyBoxWeb.Repo],
  generators: [context_app: false]

# Configures the endpoint
config :my_box_web, MyBoxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "x3TcZ9goyOvND/K77kczoeC22FYZAVFmFHbgx6JSgSf6ynTeV7EWZXC+sfpO+zPa",
  render_errors: [view: MyBoxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MyBoxWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configure Mix tasks and generators
config :my_box,
  ecto_repos: [MyBox.Repo],
  storage_providers: MyBox.Storage.Providers.GoogleCloudStorage.Local

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
