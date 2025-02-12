use Mix.Config

# Configure your database
config :the_rush, :db_config,
  name: :mongo,
  database: "theScore",
  seeds: ["mongodb:27017"],
  pool: DBConnection.Poolboy

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :the_rush, TheRushWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
