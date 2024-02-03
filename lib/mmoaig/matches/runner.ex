defmodule Mmoaig.Matches.Runner do
  use GenServer

  def start_link(match) do
    GenServer.start_link(__MODULE__, match, name: __MODULE__)
  end

  def init(match) do
    Process.send_after(self(), :stop, 30_000)
    {:ok, %{match: match}}
  end

  def handle_info(:stop, match) do
    DynamicSupervisor.terminate_child(Mmoaig.Matches.Runner.Supervisor, self())
    {:noreply, match}
  end
end
