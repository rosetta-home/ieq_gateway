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
      case device.product_id do
        24597 ->
          Logger.info("Setting IEQ TTY: #{inspect tty}")
          Application.put_env(:ieq_gateway, :tty, "/dev/#{tty}", persistent: true)
          _ -> nil
        end
      end)
    end

  end
