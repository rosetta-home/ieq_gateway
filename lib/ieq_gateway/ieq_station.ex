defmodule IEQGateway.IEQStation do
  use GenServer
  require Logger

  defmodule State do
    defstruct id: 0,
      air_temperature: 0,
      battery: 0,
      co2: 0,
      door: 0,
      energy: 0,
      pressure: 0,
      humidity: 0,
      light: 0,
      motion: 0,
      no2: 0,
      co: 0,
      pm: 0,
      rssi: 0,
      sound: 0,
      temperature: 0,
      uv: 0,
      voc: 0,
      analog_voltage: 0,
      setpoint: 0,
      diff_pressure: 0
  end

  @values %{
    "a" => :air_temperature,
    "b" => :battery,
    "c" => :co2,
    "d" => :door,
    "e" => :energy,
    "f" => :diff_pressure,
    "g" => :pressure,
    "h" => :humidity,
    "l" => :light,
    "m" => :motion,
    "n" => :no2,
    "o" => :co,
    "p" => :pm,
    "r" => :rssi,
    "s" => :sound,
    "t" => :temperature,
    "u" => :uv,
    "v" => :voc,
    "y" => :setpoint,
    "z" => :analog_voltage
  }

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: id)
  end

  def data(station, data) do
    GenServer.call(station, {:data, data})
  end

  def set_mode(station, mode) do
    GenServer.cast(station, {:set_mode, mode})
  end

  def init(id) do
    {:ok, %State{id: id}}
  end

  def handle_call({:data, data}, _from, state) do
    Logger.debug("Got Data: #{inspect data}")
    state = Enum.reduce(data, state, fn({key, value}, acc) ->
      val = case Float.parse(value) do
        {num, rem} -> num
        :error -> 0.0
      end
      struct(acc, %{@values[key] => val})
    end)
    Logger.debug("State Updated: #{inspect state}")
    GenEvent.notify(IEQGateway.Events, state)
    {:reply, state, state}
  end

  def handle_cast({:set_mode, mode}, state) do
    [_, id] =
      state.id
      |> Atom.to_string()
      |> String.split("-", parts: 2)
    IEQGateway.Client.set_station_mode(id, mode)
    {:noreply, state}
  end

end
