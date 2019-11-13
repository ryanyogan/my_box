use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :my_box_web, MyBoxWeb.Endpoint,
  http: [port: 4002],
  server: false

# Configure your database
config :my_box, MyBox.Repo,
  username: "postgres",
  password: "postgres",
  database: "my_box_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
