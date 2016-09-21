defmodule IEQGateway.EventManager do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, events} = GenEvent.start_link([{:name, IEQGateway.Events}])
    {:ok, %{:handlers => [], :events => events}}
  end

  def add_handler(handler) do
    GenServer.call(__MODULE__, {:handler, handler})
  end

  def handle_call({:handler, handler}, {pid, _} = from, state) do
    GenEvent.add_mon_handler(IEQGateway.Events, handler, pid)
    {:reply, :ok, %{state | :handlers => [{handler, pid} | state.handlers]}}
  end

  def handle_info({:gen_event_EXIT, handler, reason}, state) do
    Enum.each(state.handlers, fn(h) ->
      GenEvent.add_mon_handler(IEQGateway.Events, elem(h, 0), elem(h, 1))
    end)
    {:noreply, state}
  end

end
