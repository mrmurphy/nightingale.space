defmodule Nightingale do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Nightingale.Endpoint, []),
      # Start the Ecto repository
      supervisor(Nightingale.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(Nightingale.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nightingale.Supervisor]
    Supervisor.start_link(children, opts)

    Twitter.listener &Nightingale.TweetsChannel.broadcast_tweet/1
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Nightingale.Endpoint.config_change(changed, removed)
    :ok
  end
end
