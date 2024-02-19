defmodule Mmoaig.RockPaperScissors.GameTest do
  use Mmoaig.DataCase

  alias Mmoaig.MatchesFixtures
  alias Mmoaig.RockPaperScissors.Turn

  test "winner/1 returns the winner when first participant wins" do
    first_participant = MatchesFixtures.participant_fixture(%{id: 1})
    second_participant = MatchesFixtures.participant_fixture(%{id: 2})

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete",
      participant_id: first_participant.id,
      participant: first_participant
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("scissors"),
      status: "complete",
      participant_id: second_participant.id,
      participant: second_participant
    }

    game = %Mmoaig.Matches.Game{
      status: "complete",
      turns: [first_participant_turn, second_participant_turn]
    }

    assert Mmoaig.RockPaperScissors.Game.winner(game) == first_participant
  end

  test "winner/1 returns the winner when second participant wins" do
    first_participant = MatchesFixtures.participant_fixture(%{id: 1})
    second_participant = MatchesFixtures.participant_fixture(%{id: 2})

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete",
      participant_id: first_participant.id,
      participant: first_participant
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("paper"),
      status: "complete",
      participant_id: second_participant.id,
      participant: second_participant
    }

    game = %Mmoaig.Matches.Game{
      status: "complete",
      turns: [first_participant_turn, second_participant_turn]
    }

    assert Mmoaig.RockPaperScissors.Game.winner(game) == second_participant
  end

  test "winner/1 returns nil when it's a tie" do
    first_participant = MatchesFixtures.participant_fixture(%{id: 1})
    second_participant = MatchesFixtures.participant_fixture(%{id: 2})

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete",
      participant_id: first_participant.id,
      participant: first_participant
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "complete",
      participant_id: second_participant.id,
      participant: second_participant
    }

    game = %Mmoaig.Matches.Game{
      status: "complete",
      turns: [first_participant_turn, second_participant_turn]
    }

    assert Mmoaig.RockPaperScissors.Game.winner(game) == nil
  end

  test "winner/1 returns nil when the game is incomplete" do
    first_participant = MatchesFixtures.participant_fixture(%{id: 1})
    second_participant = MatchesFixtures.participant_fixture(%{id: 2})

    first_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("rock"),
      status: "incomplete",
      participant_id: first_participant.id,
      participant: first_participant
    }

    second_participant_turn = %Mmoaig.Matches.Turn{
      turn: Turn.build_turn_map("scissors"),
      status: "incomplete",
      participant_id: second_participant.id,
      participant: second_participant
    }

    game = %Mmoaig.Matches.Game{
      status: "incomplete",
      turns: [first_participant_turn, second_participant_turn]
    }

    assert Mmoaig.RockPaperScissors.Game.winner(game) == nil
  end
end
