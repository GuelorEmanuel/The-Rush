use Mix.Config

# Configure your database
config :the_rush, :db_config,
  name: :mongo,
  url: "mongodb+srv://guelor:#{System.get_env("MONGO_DB_PASSWORD")}@cluster0.4j8hm.mongodb.net/#{System.get_env("MONGO_CLUSTER_NAME")}?retryWrites=true&w=majority",
  pool_size: 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :the_rush, TheRushWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
