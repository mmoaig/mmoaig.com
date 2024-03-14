defmodule Mmoaig.Matches.Runner.Config do
  defstruct [
    :rounds_per_match,
    :games_per_round
  ]

  def match_complete?(match, config) do
    match.rounds
    |> Enum.filter(&(&1.status == "complete"))
    |> length() == config.rounds_per_match
  end

  def round_complete?(round, config) do
    round.games
    |> Enum.filter(&(&1.status == "complete"))
    |> length() == config.games_per_round
  end
end
