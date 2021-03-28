# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :live_song, LiveSongWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8wj7W/b4uxSOQl/nsW8aK2VwmQkGOpJGca2K8ctHlXQ8/2ki9ODei/wcUAJhzXvj",
  render_errors: [view: LiveSongWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: LiveSong.PubSub,
  live_view: [signing_salt: "6qe7FdY5"]

# Configures Elixir's Logger
config :logger,
  backends: [:console, LiveSong.ChannelLogsBackend]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
