defmodule Mmoaig.Matches.Gateway do
  use GenServer

  @registry Mmoaig.Matches.Runner.Gateway.Registry

  def start_link(match_id, adapter) do
    GenServer.start_link(__MODULE__, {match_id, adapter}, name: via_tuple(match_id))
  end

  def request_turn(match_id, turn) do
    GenServer.cast(via_tuple(match_id), {:request_turn, turn})
  end

  def init({match_id, adapter}) do
    {:ok, {match_id, adapter}}
  end

  def handle_cast({:request_turn, turn}, {match_id, adapter}) do
    GenServer.cast(adapter, {:request_turn, turn})
    {:noreply, {match_id, adapter}}
  end

  defp via_tuple(match_id) do
    {:via, Registry, {@registry, match_id}}
  end
end
