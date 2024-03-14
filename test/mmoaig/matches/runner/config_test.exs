defmodule Mmoaig.Matches.Runner.ConfigTest do
  use Mmoaig.DataCase

  alias Mmoaig.Matches.Runner.Config
  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Round
  alias Mmoaig.Matches.Game

  test "match_complete? returns true when the match has the expected number of complete rounds" do
    config = %Config{rounds_per_match: 2, games_per_round: 2}

    rounds = [
      %Round{status: "complete"},
      %Round{status: "complete"}
    ]

    match = %Match{rounds: rounds}
    assert Config.match_complete?(match, config)
  end

  test "match_complete? returns false when the match does not have the expected number of complete rounds" do
    config = %Config{rounds_per_match: 2, games_per_round: 2}

    rounds = [
      %Round{status: "complete"},
      %Round{status: "in_progress"}
    ]

    match = %Match{rounds: rounds}
    refute Config.match_complete?(match, config)
  end

  test "round_complete? returns true when the round has the expected number of complete games" do
    config = %Config{rounds_per_match: 2, games_per_round: 2}

    games = [
      %Game{status: "complete"},
      %Game{status: "complete"}
    ]

    round = %Round{games: games}
    assert Config.round_complete?(round, config)
  end

  test "round_complete? returns false when the round does not have the expected number of complete games" do
    config = %Config{rounds_per_match: 2, games_per_round: 2}

    games = [
      %Game{status: "complete"},
      %Game{status: "in_progress"}
    ]

    round = %Round{games: games}
    refute Config.round_complete?(round, config)
  end
end
