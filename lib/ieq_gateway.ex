defmodule IEQGateway do
  require Logger

  defmodule Modes do
    defstruct white: "0",
      red: "1",
      green: "2",
      blue: "3",
      yellow: "4",
      off: "5",
      cycle: "6"
  end

  def set_station_mode(station, mode) do
    IEQGateway.Client.set_station_mode(station, mode)
  end
end
