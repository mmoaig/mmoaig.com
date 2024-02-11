defmodule Mmoaig.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MmoaigWeb.Telemetry,
      Mmoaig.Repo,
      {DNSCluster, query: Application.get_env(:mmoaig, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Mmoaig.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Mmoaig.Finch},
      # Start a worker by calling: Mmoaig.Worker.start_link(arg)
      # {Mmoaig.Worker, arg},
      {DynamicSupervisor, name: Mmoaig.Matches.Runner.Supervisor, strategy: :one_for_one},
      {Registry, [keys: :unique, name: Mmoaig.Matches.Runner.Registry]},
      {Registry, [keys: :unique, name: Mmoaig.Matches.Runner.Gateway.Registry]},
      # Start to serve requests, typically the last entry
      MmoaigWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mmoaig.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MmoaigWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
