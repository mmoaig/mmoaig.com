defmodule Mmoaig.RockPaperScissors.TurnTest do
  use Mmoaig.DataCase

  alias Mmoaig.RockPaperScissors.Turn

  test "build_turn_map/1 returns a map with the turn" do
    assert Turn.build_turn_map("rock") == %{turn: "rock"}
    assert Turn.build_turn_map("paper") == %{turn: "paper"}
    assert Turn.build_turn_map("scissors") == %{turn: "scissors"}

    assert_raise FunctionClauseError, fn -> Turn.build_turn_map("invalid") end
  end

  test "winner/2 returns the winner when first participant wins" do
    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("scissors"),
      status: "complete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == first_participant_turn

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("paper"),
      status: "complete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == first_participant_turn

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("scissors"),
      status: "complete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("paper"),
      status: "complete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == first_participant_turn
  end

  test "winner/2 returns the winner when second participant wins" do
    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("paper"),
      status: "complete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == second_participant_turn

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("paper"),
      status: "complete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("scissors"),
      status: "complete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == second_participant_turn

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("scissors"),
      status: "complete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == second_participant_turn
  end

  test "winner/2 returns nil when it's a tie" do
    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == nil
  end

  test "winner/2 returns nil when turns are incomplete" do
    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "incomplete"
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("scissors"),
      status: "incomplete"
    }

    assert Turn.winner(first_participant_turn, second_participant_turn) == nil
  end
end
