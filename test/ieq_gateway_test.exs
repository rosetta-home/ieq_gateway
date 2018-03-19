defmodule IEQGatewayTest do
  use ExUnit.Case
  doctest IEQGateway
  require Logger
  
  test "the truth" do
    assert 1 + 1 == 2
  end

  test "parse" do
    assert %{} = IEQGateway.Client.parse_data("i:300,r:-42,c:400")
    assert :error = IEQGateway.Client.parse_data("dsjkfhsaldifysaoidfuyoaisudyfoiasdyfoiausdyfoiuasydfiouasydfoiuasydfiouasydfoiasydfoiusydfoiasdyfoisydfiaousdyf,r:-889")
  end

  test "events" do
    [tty] = get_tty()
    Logger.info "Starting IEQ Sensor Listener: #{tty}"
    tty |> IEQGateway.Supervisor.start_link()
    IEQGateway.EventManager.add_handler(IEQGateway.Handler)
    assert_receive %IEQGateway.IEQStation.State{}, 30_000
  end

  def get_tty do
    Nerves.UART.enumerate |> Enum.flat_map(fn({tty, device}) ->
      Logger.debug("#{inspect device}")
      case Map.get(device, :product_id, 0) do
        24597 ->
          Logger.debug("Setting IEQ TTY: #{inspect tty}")
          case String.starts_with?(tty, "/dev") do
            true -> [tty]
            false -> ["/dev/#{tty}"]
          end
        _ -> []
      end
    end)
  end
end
