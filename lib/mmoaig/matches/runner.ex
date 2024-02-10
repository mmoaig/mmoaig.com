defmodule Mmoaig.Matches.Runner do
  use GenServer

  alias Mmoaig.Matches

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(match) do
    GenServer.start_link(__MODULE__, match, name: __MODULE__)
  end

  def init(match) do
    Process.send_after(self(), :start_match, 1_000)
    {:ok, match}
  end

  def handle_info(:start_match, match) do
    {:ok, match} = Matches.update_match(match, %{status: "in-progress"})
    Process.send_after(self(), :complete_match, 10_000)
    {:noreply, match}
  end

  def handle_info(:complete_match, match) do
    {:ok, match} = Matches.update_match(match, %{status: "complete"})
    Process.send_after(self(), :stop, 1_000)
    {:noreply, match}
  end

  def handle_info(:stop, match) do
    DynamicSupervisor.terminate_child(Mmoaig.Matches.Runner.Supervisor, self())
    {:noreply, match}
  end
end
