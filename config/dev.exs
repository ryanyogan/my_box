use Mix.Config

# Configure your database
config :my_box, MyBox.Repo,
  username: "postgres",
  password: "postgres",
  database: "my_box_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
