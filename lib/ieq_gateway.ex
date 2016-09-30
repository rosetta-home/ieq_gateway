defmodule IEQGateway do
  use Application
  require Logger
  alias Nerves.UART, as: Serial

  def start(_type, _args) do
    get_tty
    {:ok, pid} = IEQGateway.Supervisor.start_link
  end

  def get_tty do
    Serial.enumerate |> Enum.each(fn({tty, device}) ->
      Logger.info("#{inspect device}")
      case Map.get(device, :product_id, 0) do
        24597 ->
          Logger.info("Setting IEQ TTY: #{inspect tty}")
          tty = case String.starts_with?(tty, "/dev") do
            true -> tty
            false -> "/dev/#{tty}"
          end
          Application.put_env(:ieq_gateway, :tty, tty, persistent: true)
        _ -> nil
      end
    end)
  end
end
