use Mix.Config

# Configure your database
config :my_box, MyBox.Repo,
  username: "postgres",
  password: "postgres",
  database: "my_box_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
