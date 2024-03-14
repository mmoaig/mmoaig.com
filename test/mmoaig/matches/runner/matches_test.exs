defmodule Mmoaig.Matches.Runner.MatchesTest do
  alias Mmoaig.Matches
  use Mmoaig.DataCase

  alias Mmoaig.MatchesFixtures
  alias Mmoaig.Repo
  alias Mmoaig.Matches.Round
  alias Mmoaig.Matches.Runner.Matches
  alias Mmoaig.Matches.Runner.Config

  describe "start_match/1" do
    test "starts pending matches" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      assert match.status == "in-progress"
    end

    test "creates an initial round for pending matches" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      assert [%{match_id: match_id, status: "pending"}] = Repo.all(Round)
      assert match.id == match_id
    end

    test "enters a log message when the match is pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      assert [] = Mmoaig.Matches.list_log_messages(match.id)
      {:ok, match} = Matches.start_match(match)

      assert [%{level: "info", message: "Match started"}] =
               Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if the match is not pending" do
      match = MatchesFixtures.match_fixture(status: "in-progress")
      assert_raise FunctionClauseError, fn -> Matches.start_match(match) end
    end

    test "does not create an initial round for matches that are not pending" do
      match = MatchesFixtures.match_fixture(status: "in-progress")
      assert_raise FunctionClauseError, fn -> Matches.start_match(match) end
      assert [] == Repo.all(Round)
    end

    test "does not enter a log message if the match is not pending" do
      match = MatchesFixtures.match_fixture(status: "in-progress")
      assert_raise FunctionClauseError, fn -> Matches.start_match(match) end
      assert [] == Mmoaig.Matches.list_log_messages(match.id)
    end
  end

  describe "complete_match/1" do
    test "completes in progress matches" do
      match = MatchesFixtures.match_fixture(status: "in-progress")
      {:ok, match} = Matches.complete_match(match)
      assert match.status == "complete"
    end

    test "enters a log message when the match is in progress" do
      match = MatchesFixtures.match_fixture(status: "in-progress")
      {:ok, match} = Matches.complete_match(match)

      assert [%{level: "info", message: "Match started"}] =
               Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if match is not in progress" do
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise FunctionClauseError, fn -> Matches.complete_match(match) end
    end

    test "does not enter a log message if the match is not in progress" do
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise FunctionClauseError, fn -> Matches.complete_match(match) end
      assert [] = Mmoaig.Matches.list_log_messages(match.id)
    end
  end

  describe "start_current_round/1" do
    test "starts the current round when it is pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      round = Matches.current_round(match)

      assert round.status == "in-progress"
    end

    test "creates an initial game for pending round" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      round = Matches.current_round(match)
      %{id: round_id} = round
      assert [%{round_id: ^round_id, status: "pending"}] = round.games
    end

    test "enters a log message when the current round is pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      Matches.start_current_round(match)

      assert [%{message: "Round started"}, _match_started_log] =
               Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if the current round is not pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      assert_raise FunctionClauseError, fn -> Matches.start_current_round(match) end
    end

    test "does not enter a log message if the current round is not pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      assert_raise FunctionClauseError, fn -> Matches.start_current_round(match) end

      assert [%{message: "Round started"}, _match_started_log] =
               Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if the current round is nil" do
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise Protocol.UndefinedError, fn -> Matches.start_current_round(match) end
    end

    test "does not enter a log message if the current round is nil" do
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise Protocol.UndefinedError, fn -> Matches.start_current_round(match) end
      assert [] = Mmoaig.Matches.list_log_messages(match.id)
    end
  end

  describe "complete_current_round/1" do
    test "completes the current round when it is in progress" do
      config = %Config{rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.complete_current_round(match, config)

      assert [%{status: "complete"}, _new_round] = match.rounds
    end

    test "enters a log message when the current round is in progress" do
      config = %Config{rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.complete_current_round(match, config)

      assert [
               %{level: "info", message: "Round completed"},
               _round_started_log,
               _match_started_log
             ] = Mmoaig.Matches.list_log_messages(match.id)
    end

    test "creates a new round when the match is not complete" do
      config = %Config{rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.complete_current_round(match, config)

      assert [%{status: "complete"}, %{status: "pending"}] = match.rounds
    end

    test "does not create a new round when the match is complete" do
      config = %Config{rounds_per_match: 1}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.complete_current_round(match, config)

      assert [%{status: "complete"}] = match.rounds
    end

    test "raises if the current round is not in progress" do
      config = %Config{rounds_per_match: 1}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      assert_raise FunctionClauseError, fn -> Matches.complete_current_round(match, config) end
    end

    test "does not enter a log message if the current round is not in progress" do
      config = %Config{rounds_per_match: 1}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      assert_raise FunctionClauseError, fn -> Matches.complete_current_round(match, config) end
      assert [_start_match_log_message] = Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if the current round is nil" do
      config = %Config{rounds_per_match: 1}
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise ArgumentError, fn -> Matches.complete_current_round(match, config) end
    end

    test "does not enter a log message if the current round is nil" do
      config = %Config{rounds_per_match: 1}
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise ArgumentError, fn -> Matches.complete_current_round(match, config) end
      assert [] = Mmoaig.Matches.list_log_messages(match.id)
    end
  end

  describe "start_current_game/1" do
    test "starts the current game when it is pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.start_current_game(match)
      current_round = Matches.current_round(match)
      [game] = current_round.games

      assert game == Matches.current_game(match)
      assert game.status == "in-progress"
    end

    test "enters a log message when the current game is pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.start_current_game(match)

      assert [%{message: "Game started"}, _round_started_log, _match_started_log] =
               Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if the current game is not pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.start_current_game(match)
      assert_raise FunctionClauseError, fn -> Matches.start_current_game(match) end
    end

    test "does not enter a log message if the current game is not pending" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.start_current_game(match)
      assert_raise FunctionClauseError, fn -> Matches.start_current_game(match) end

      assert [%{message: "Game started"}, _round_started_log, _match_started_log] =
               Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if the current game is nil" do
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise Protocol.UndefinedError, fn -> Matches.start_current_game(match) end
    end

    test "does not enter a log message if the current game is nil" do
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise Protocol.UndefinedError, fn -> Matches.start_current_game(match) end
      assert [] = Mmoaig.Matches.list_log_messages(match.id)
    end
  end

  describe "complete_current_game/1" do
    test "completes the current game when it is in progress" do
      config = %Config{games_per_round: 1, rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.start_current_game(match)
      {:ok, match} = Matches.complete_current_game(match, config)

      %{games: [current_game]} = Matches.current_round(match)

      assert current_game.status == "complete"
    end

    test "enters a log message when the current game is in progress" do
      config = %Config{games_per_round: 2, rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.start_current_game(match)
      {:ok, match} = Matches.complete_current_game(match, config)

      assert [
               %{level: "info", message: "Game completed"},
               _game_started_log,
               _round_started_log,
               _match_started_log
             ] = Mmoaig.Matches.list_log_messages(match.id)
    end

    test "creates a new game when the round is not complete" do
      config = %Config{games_per_round: 2, rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      {:ok, match} = Matches.start_current_game(match)
      {:ok, match} = Matches.complete_current_game(match, config)

      %{games: [_current_game, new_game]} = Matches.current_round(match)
      assert new_game.status == "pending"
    end

    test "raises if the current game is not in progress" do
      config = %Config{games_per_round: 1, rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      assert_raise FunctionClauseError, fn -> Matches.complete_current_game(match, config) end
    end

    test "does not enter a log message if the current game is not in progress" do
      config = %Config{games_per_round: 1, rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      assert_raise FunctionClauseError, fn -> Matches.complete_current_game(match, config) end
      assert [_round_started_log, _match_started_log] = Mmoaig.Matches.list_log_messages(match.id)
    end

    test "raises if the current game is nil" do
      config = %Config{games_per_round: 1, rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise Protocol.UndefinedError, fn -> Matches.complete_current_game(match, config) end
    end

    test "does not enter a log message if the current game is nil" do
      config = %Config{games_per_round: 1, rounds_per_match: 2}
      match = MatchesFixtures.match_fixture(status: "pending")
      assert_raise Protocol.UndefinedError, fn -> Matches.complete_current_game(match, config) end
      assert [] = Mmoaig.Matches.list_log_messages(match.id)
    end
  end

  describe "current_game/1" do
    test "returns the current game" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      {:ok, match} = Matches.start_current_round(match)
      round = Matches.current_round(match)
      [game] = round.games

      assert game == Matches.current_game(match)
    end

    test "returns nil if there is no current game" do
      match = MatchesFixtures.match_fixture(status: "pending")
      match = %{match | rounds: [%{match_id: match.id, status: "pending", games: []}]}
      assert Matches.current_game(match) == nil
    end

    test "returns nil if there is no current round" do
      match = MatchesFixtures.match_fixture(status: "pending")
      match = %{match | rounds: []}
      assert Matches.current_game(match) == nil
    end
  end

  describe "current_round/1" do
    test "returns the current round" do
      match = MatchesFixtures.match_fixture(status: "pending")
      {:ok, match} = Matches.start_match(match)
      [round] = match.rounds
      assert round == Matches.current_round(match)
      assert round.status == "pending"
    end

    test "returns nil if there is no current round" do
      match = MatchesFixtures.match_fixture(status: "pending")
      match = %{match | rounds: []}
      assert Matches.current_round(match) == nil
    end
  end
end
