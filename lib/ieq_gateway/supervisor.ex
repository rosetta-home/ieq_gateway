defmodule IEQGateway.Supervisor do
  use Supervisor

  def start_link(tty) do
    Supervisor.start_link(__MODULE__, tty, name: __MODULE__)
  end

  def init(tty) do
    children = [
      worker(IEQGateway.Client, [tty]),
      worker(IEQGateway.EventManager, []),
      supervisor(IEQGateway.StationSupervisor, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
