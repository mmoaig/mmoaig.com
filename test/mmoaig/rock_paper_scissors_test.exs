defmodule Mmoaig.RockPaperScissorsTest do
  use Mmoaig.DataCase

  alias Mmoaig.RockPaperScissors
  alias Mmoaig.Matches.Turn
  alias Mmoaig.Matches.Game

  test "game_complete?/1 returns true when 50 moves have been made" do
    game = %Game{
      turns: Enum.map(1..50, fn _ -> %Turn{} end)
    }

    assert RockPaperScissors.game_complete?(game)
  end

  test "game_complete?/1 returns false when fewer than 50 moves have been made" do
    game = %Game{
      turns: Enum.map(1..49, fn _ -> %Turn{} end)
    }

    refute RockPaperScissors.game_complete?(game)
  end

  test "game_winner/1 returns the winner when first participant wins" do
    winning_participant = %{id: "whatever"}

    game = %Game{
      status: "complete",
      turns: [
        %Turn{
          turn: %{turn: "rock"},
          status: "complete",
          participant_id: 1,
          participant: winning_participant
        },
        %Turn{
          turn: %{turn: "scissors"},
          status: "complete",
          participant_id: 2,
          participant: %{}
        }
      ]
    }

    assert RockPaperScissors.game_winner(game) == winning_participant
  end

  test "game_winner/1 returns the winner when second participant wins" do
    winning_participant = %{id: "whatever"}

    game = %Game{
      status: "complete",
      turns: [
        %Turn{
          turn: %{turn: "scissors"},
          status: "complete",
          participant_id: 1,
          participant: %{}
        },
        %Turn{
          turn: %{turn: "rock"},
          status: "complete",
          participant_id: 2,
          participant: winning_participant
        }
      ]
    }

    assert RockPaperScissors.game_winner(game) == winning_participant
  end

  test "game_winner/1 returns nil when nobody has won" do
    game = %Game{
      status: "complete",
      turns: [
        %Turn{
          turn: %{turn: "rock"},
          status: "complete",
          participant_id: 1,
          participant: %{}
        },
        %Turn{
          turn: %{turn: "rock"},
          status: "complete",
          participant_id: 2,
          participant: %{}
        }
      ]
    }

    assert RockPaperScissors.game_winner(game) == nil
  end

  test "move_valid?/1 returns true when the move is valid" do
    assert RockPaperScissors.move_valid?("rock")
    assert RockPaperScissors.move_valid?("paper")
    assert RockPaperScissors.move_valid?("scissors")
  end

  test "move_valid?/1 returns false when the move is invalid" do
    refute RockPaperScissors.move_valid?("lizard")
  end

  test "build_turn_map/1 returns a map with the turn" do
    assert RockPaperScissors.build_turn_map("rock") == %{turn: "rock"}
    assert RockPaperScissors.build_turn_map("paper") == %{turn: "paper"}
    assert RockPaperScissors.build_turn_map("scissors") == %{turn: "scissors"}
  end

  test "current_turn/2 returns the current turn" do
    first_participant = %{participant_number: 1}
    second_participant = %{participant_number: 2}

    game = %Game{
      turns: [
        %Turn{
          participant_id: 1,
          participant: first_participant
        }
      ]
    }

    assert RockPaperScissors.current_turn([first_participant, second_participant], game) ==
             second_participant

    game = %Game{
      turns: [
        %Turn{
          participant_id: 1,
          participant: first_participant
        },
        %Turn{
          participant_id: 2,
          participant: second_participant
        }
      ]
    }

    assert RockPaperScissors.current_turn([first_participant, second_participant], game) ==
             first_participant
  end
end
