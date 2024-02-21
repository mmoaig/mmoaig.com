defmodule Mmoaig.Matches.Runner do
  @registry Mmoaig.Matches.Runner.Registry
  use GenServer

  alias Mmoaig.Matches
  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Gateway
  alias Mmoaig.Matches.Game

  @time_between_turns 500

  def record_turn(match, turn) do
    GenServer.cast(via_tuple(match), {:record_turn, turn})
  end

  def start_link(match) do
    GenServer.start_link(__MODULE__, match, name: via_tuple(match))
  end

  def init(match) do
    Process.send_after(self(), :start_match, 1_000)

    current_game =
      match
      |> Matches.get_current_game()
      |> Game.load_turns()

    Matches.create_log_message(
      "info",
      %{
        match_id: match.id,
        message: "Match runner started"
      }
    )

    {:ok, {match, current_game}}
  end

  def handle_info(:start_match, {match, current_game}) do
    {:ok, match} = Matches.update_match(match, %{status: "in-progress"})

    match = Match.load_participants(match)

    Matches.create_log_message("info", %{match_id: match.id, message: "Match started"})

    GenServer.cast(self(), :run_next_game)
    {:noreply, {match, current_game}}
  end

  def handle_info(:stop, {match, current_game}) do
    Matches.create_log_message("info", %{
      match_id: match.id,
      message: "Match runner stopped"
    })

    DynamicSupervisor.terminate_child(Mmoaig.Matches.Runner.Supervisor, self())
    {:noreply, {match, current_game}}
  end


  def handle_info(:run_next_turn, {match, current_game}) do
    game_logic = Mmoaig.Events.game_logic(match.event)

    participant_to_move = game_logic.current_turn(match.participants, current_game)

    {:ok, turn} =
      Matches.create_turn(%{
        game_id: current_game.id,
        participant_id: participant_to_move.id,
        status: "pending"
      })

    Gateway.request_turn(match.id, turn)

    current_game = Map.update(current_game, :turns, [], &[turn | &1])

    {:noreply, {match, current_game}}
  end

  def handle_cast(:run_next_game, {match, current_game}) do
    queue_next_turn(self())
    {:noreply, {match, current_game}}
  end

  def handle_cast(:complete_match, {match, current_game}) do
    {:ok, match} = Matches.update_match(match, %{status: "complete"})
    Matches.create_log_message("info", %{match_id: match.id, message: "Match completed"})
    Process.send_after(self(), :stop, 1_000)
    {:noreply, {match, current_game}}
  end

  def handle_cast({:record_turn, turn}, {match, current_game}) do
    game_logic = Mmoaig.Events.game_logic(match.event)

    {:ok, turn} =
      turn
      |> Map.get("turnId")
      |> Matches.get_turn!()
      |> Matches.update_turn(%{status: "complete", turn: game_logic.build_turn_map(turn["data"])})

    current_game =
      Map.update(current_game, :turns, [], fn turns ->
        Enum.map(turns, fn t ->
          if t.id == turn.id, do: turn, else: t
        end)
      end)

    if game_logic.game_complete?(current_game) do
      GenServer.cast(self(), :complete_match)
    else
      queue_next_turn(self())
    end

    {:noreply, {match, current_game}}
  end

  defp queue_next_turn(runner) do
    Process.send_after(runner, :run_next_turn, @time_between_turns)
  end

  defp via_tuple(match) do
    {:via, Registry, {@registry, match.runner_token}}
  end
end
