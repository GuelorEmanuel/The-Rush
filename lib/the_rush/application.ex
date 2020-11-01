defmodule TheRush.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TheRushWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TheRush.PubSub},
      # Start the Endpoint (http/https)
      TheRushWeb.Endpoint
      # Start a worker by calling: TheRush.Worker.start_link(arg)
      # {TheRush.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TheRush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TheRushWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
