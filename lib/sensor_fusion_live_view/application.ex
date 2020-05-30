defmodule SensorFusionLiveView.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SensorFusionLiveView.Repo,
      # Start the Telemetry supervisor
      SensorFusionLiveViewWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SensorFusionLiveView.PubSub},
      # Start the Endpoint (http/https)
      SensorFusionLiveViewWeb.Endpoint,

      SensorFusionLiveView.Multicast
      # Start a worker by calling: SensorFusionLiveView.Worker.start_link(arg)
      # {SensorFusionLiveView.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SensorFusionLiveView.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SensorFusionLiveViewWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
