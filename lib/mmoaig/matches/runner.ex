defmodule Mmoaig.Matches.Runner do
  @registry Mmoaig.Matches.Runner.Registry
  use GenServer

  alias Mmoaig.Matches
  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Gateway

  def start_link(match) do
    GenServer.start_link(__MODULE__, match, name: via_tuple(match))
  end

  def init(match) do
    Process.send_after(self(), :start_match, 1_000)
    Matches.create_log_message("info", %{match_id: match.id, message: "Match runner started"})
    {:ok, match}
  end

  def handle_info(:start_match, match) do
    {:ok, match} = Matches.update_match(match, %{status: "in-progress"})

    match = Match.load_participants(match)

    Matches.create_log_message("info", %{match_id: match.id, message: "Match started"})

    Enum.each(match.participants, fn participant ->
      Gateway.request_turn(match.id, participant.id)
    end)

    Process.send_after(self(), :complete_match, 10_000)
    {:noreply, match}
  end

  def handle_info(:complete_match, match) do
    {:ok, match} = Matches.update_match(match, %{status: "complete"})
    Matches.create_log_message("info", %{match_id: match.id, message: "Match completed"})
    Process.send_after(self(), :stop, 1_000)
    {:noreply, match}
  end

  def handle_info(:stop, match) do
    Matches.create_log_message("info", %{
      match_id: match.id,
      message: "Match runner stopped"
    })

    DynamicSupervisor.terminate_child(Mmoaig.Matches.Runner.Supervisor, self())
    {:noreply, match}
  end

  defp via_tuple(match) do
    {:via, Registry, {@registry, match.runner_token}}
  end
end
