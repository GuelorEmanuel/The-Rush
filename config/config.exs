# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configure your database
config :the_rush, :db_config,
  name: :mongo,
  url: "mongodb+srv://guelor:#{System.get_env("MONGO_DB_PASSWORD")}@cluster0.4j8hm.mongodb.net/#{System.get_env("MONGO_CLUSTER_NAME")}?retryWrites=true&w=majority",
  pool_size: 2

# Configures the endpoint
config :the_rush, TheRushWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "H7BY3C6+BI5s0P02OSK3lS7iavyK3SLbngvSMZ/mOwlHFR8PQqgS4Ou006TKrh+8",
  render_errors: [view: TheRushWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TheRush.PubSub,
  live_view: [signing_salt: "KQmLK4Hw"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
