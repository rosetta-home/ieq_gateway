defmodule IEQGateway.IEQStation do
  use GenServer
  require Logger

  defmodule State do
    defstruct id: 0,
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
      voc: 0
  end

  @values %{
    "b" => :battery,
    "c" => :co2,
    "d" => :door,
    "e" => :energy,
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
    "v" => :voc
  }

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: id)
  end

  def data(station, data) do
    GenServer.call(station, {:data, data})
  end

  def init(id) do
    {:ok, %State{id: id}}
  end

  def handle_call({:data, data}, _from, state) do
    Logger.debug("Got Data: #{inspect data}")
    state = Enum.reduce(data, state, fn({key, value}, acc) ->
      val = Float.parse(value) |> elem(0)
      struct(acc, %{@values[key] => val})
    end)
    Logger.debug("State Updated: #{inspect state}")
    GenEvent.notify(IEQGateway.Events, state)
    {:reply, state, state}
  end

end
