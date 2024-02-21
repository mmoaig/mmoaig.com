defmodule Mmoaig.GameLogic do
  alias Mmoaig.Matches.Game
  alias Mmoaig.Matches.Participant
  alias Mmoaig.Matches.Move

  @callback current_turn(participants :: list(Participant.t()), game :: Game.t()) ::
              Participant.t() | nil
  @callback game_complete?(game :: Game.t()) :: boolean
  @callback game_winner(game :: Game.t()) :: Participant.t() | nil
  @callback move_valid?(move :: Move.t()) :: boolean
  @callback build_turn_map(raw_move :: any()) :: Map.t()
end
