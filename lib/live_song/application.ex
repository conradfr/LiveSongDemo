defmodule LiveSong.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveSongWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveSong.PubSub},
      {Registry, [keys: :unique, name: LiveSongRadioProviderRegistry]},
      {DynamicSupervisor, strategy: :one_for_one, name: LiveSong.RadioDynamicSupervisor},
      LiveSongWeb.Presence,
      # Start the Endpoint (http/https)
      LiveSongWeb.Endpoint
      # Start a worker by calling: LiveSong.Worker.start_link(arg)
      # {LiveSong.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveSong.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LiveSongWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
