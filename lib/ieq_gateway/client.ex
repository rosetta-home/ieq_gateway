defmodule IEQGateway.Client do
  use GenServer
  require Logger
  alias Nerves.UART, as: Serial

  defmodule State do
    defstruct stations: []
  end

  def set_station_mode(station, mode) do
    GenServer.cast(__MODULE__, {:set_station_mode, station, mode})
  end

  def start_link(tty) do
    GenServer.start_link(__MODULE__, tty, name: __MODULE__)
  end

  def init(tty) do
    speed = Application.get_env(:ieq_gateway, :speed)
    {:ok, serial} = Serial.start_link([{:name, IEQGateway.Serial}])
    Logger.debug "Starting Serial: #{tty}"
    Serial.configure(IEQGateway.Serial, framing: {Serial.Framing.Line, separator: "\r\n"})
    Serial.open(IEQGateway.Serial, tty, speed: speed, active: true)
    {:ok, %State{}}
  end

  def handle_cast({:set_station_mode, station, mode}, state) do
    IEQGateway.Serial |> Serial.write("#{station},#{mode}n")
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _serial, {:partial, _data}}, state) do
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _serial, {:error, :ebadf}}, state) do
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _serial, data}, state) do
    payload = data
    |> String.split(",")
    |> Enum.map(fn(kv) ->
      String.split(kv, ":") |> List.to_tuple
    end)
    |> Enum.into(%{})

    case Map.has_key?(payload, "i") do
      true -> handle_data(payload, state)
      _ -> :ok
    end

    {:noreply, state}
  end

  def handle_data(data, state) do
    id = :"IEQStation-#{data["i"]}"
    data = Map.drop(data, ["i"])
    state =
      case Process.whereis(id) do
        nil ->
          IEQGateway.StationSupervisor.start_station(id)
          %State{state | :stations => [id | state.stations]}
          _ -> state
        end
        IEQGateway.IEQStation.data(id, data)
        state
      end

    end
