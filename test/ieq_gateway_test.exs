defmodule IEQGatewayTest do
  use ExUnit.Case
  doctest IEQGateway

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "events" do
      IEQGateway.EventManager.add_handler(IEQGateway.Handler)
      assert_receive %IEQGateway.IEQStation.State{}, 30_000
  end
end
