defmodule IEQGateway.StationSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(IEQGateway.IEQStation, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_station(id) do
    Logger.debug "Starting station: #{inspect id}"
    Supervisor.start_child(__MODULE__, [id])
  end
end
