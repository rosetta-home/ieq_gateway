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
    state =
      with %{} = payload <- data |> parse_data,
        state <- payload |> handle_data(state) do
        state
      else
        error -> state
      end
    {:noreply, state}
  end

  def parse_data(data) do
    with parts <- data |> String.split(","),
      tuples <- parts |> Enum.map(fn k -> k |> String.split(":") |> List.to_tuple end),
      %{} = payload <- tuples |> to_map(),
      true <- payload |> Map.has_key?("i") do
      payload
    else
      error ->
        Logger.error("Bad Data: #{inspect data}")
        :error
    end
  end

  defp to_map(tuples) do
    try do
      tuples |> Enum.into(%{})
    rescue
      error -> %{}
    end
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
