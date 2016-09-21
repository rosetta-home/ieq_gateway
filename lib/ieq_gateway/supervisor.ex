defmodule IEQGateway.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(IEQGateway.Client, []),
      worker(IEQGateway.EventManager, []),
      supervisor(IEQGateway.StationSupervisor, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
