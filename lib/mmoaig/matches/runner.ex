defmodule Mmoaig.Matches.Runner do
  @registry Mmoaig.Matches.Runner.Registry
  use GenServer

  alias Mmoaig.Matches
  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Gateway

  def record_turn(match, turn) do
    GenServer.cast(via_tuple(match), {:record_turn, turn})
  end

  def start_link(match) do
    GenServer.start_link(__MODULE__, match, name: via_tuple(match))
  end

  def init(match) do
    Process.send_after(self(), :start_match, 1_000)

    Matches.create_log_message(
      "info",
      %{
        match_id: match.id,
        message: "Match runner started"
      }
    )

    {:ok, match}
  end

  def handle_info(:start_match, match) do
    {:ok, match} = Matches.update_match(match, %{status: "in-progress"})

    match = Match.load_participants(match)

    Matches.create_log_message("info", %{match_id: match.id, message: "Match started"})

    Process.send_after(self(), :create_turn, 5_000)
    {:noreply, match}
  end

  def handle_info(:create_turn, match) do
    Process.send_after(self(), :complete_match, 5_000)

    current_participant = Enum.min_by(match.participants, & &1.participant_number)
    current_game = Matches.get_current_game(match)

    {:ok, turn} =
      Matches.create_turn(%{
        game_id: current_game.id,
        participant_id: current_participant.id,
        status: "pending"
      })

    Gateway.request_turn(match.id, turn)

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

  def handle_cast({:record_turn, turn}, match) do
    {:ok, _turn} =
      turn
      |> Map.get("turnId")
      |> Matches.get_turn!()
      |> Matches.update_turn(%{status: "complete", turn: %{thow: turn["data"]}})

    {:noreply, match}
  end

  defp via_tuple(match) do
    {:via, Registry, {@registry, match.runner_token}}
  end
end
