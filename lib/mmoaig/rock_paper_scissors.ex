defmodule Mmoaig.RockPaperScissors do
  @behaviour Mmoaig.GameLogic

  alias Mmoaig.RockPaperScissors.Turn
  alias Mmoaig.RockPaperScissors.Game

  def current_turn([first_participant, second_participant], game) do
    parity =
      game.turns
      |> length()
      |> rem(2)

    case parity do
      0 -> first_participant
      1 -> second_participant
    end
  end

  def build_turn_map(raw_turn), do: Turn.build_turn_map(raw_turn)
  def game_winner(game), do: Game.winner(game)
  def move_valid?(raw_turn), do: Enum.member?(["rock", "paper", "scissors"], raw_turn)
  def game_complete?(game), do: Game.complete?(game)
end
