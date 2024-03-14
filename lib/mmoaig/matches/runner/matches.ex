defmodule Mmoaig.Matches.Runner.Matches do
  alias Mmoaig.Matches.Match
  alias Mmoaig.Repo
  alias Mmoaig.Matches.Round
  alias Mmoaig.Matches.Game
  alias Mmoaig.Matches.Runner.Config
  alias Ecto.Multi

  @spec start_match(Match.t()) :: Match.t()
  def start_match(%Match{status: "pending"} = match) do
    {:ok, %{match: match, round: round}} =
      Multi.new()
      |> Multi.update(:match, Match.changeset(match, %{status: "in-progress"}))
      |> Multi.insert(
        :round,
        Round.changeset(%Round{}, %{match_id: match.id, status: "pending"})
      )
      |> Multi.run(:log_message, fn _repo, _multi ->
        Mmoaig.Matches.create_log_message("info", %{match_id: match.id, message: "Match started"})
      end)
      |> Repo.transaction()

    {:ok, %{match | rounds: [round]}}
  end

  @spec complete_match(Match.t()) :: Match.t()
  def complete_match(%Match{status: "in-progress"} = match) do
    {:ok, %{match: match}} =
      Multi.new()
      |> Multi.update(:match, Match.changeset(match, %{status: "complete"}))
      |> Multi.insert(
        :round,
        Round.changeset(%Round{}, %{match_id: match.id, status: "pending"})
      )
      |> Multi.run(:log_message, fn _repo, _multi ->
        Mmoaig.Matches.create_log_message("info", %{match_id: match.id, message: "Match started"})
      end)
      |> Repo.transaction()

    {:ok, match}
  end

  @spec start_current_round(Match.t()) :: Match.t()
  def start_current_round(match) do
    {:ok, round} =
      match
      |> current_round()
      |> start_round()

    rounds = replace_by_id(match.rounds, round)
    {:ok, %Match{match | rounds: rounds}}
  end

  defp start_round(%Round{status: "pending"} = round) do
    {:ok, %{game: game, round: round}} =
      Multi.new()
      |> Multi.update(:round, Round.changeset(round, %{status: "in-progress"}))
      |> Multi.insert(
        :game,
        Game.changeset(%Game{}, %{round_id: round.id, status: "pending"})
      )
      |> Multi.run(:log_message, fn _repo, _multi ->
        Mmoaig.Matches.create_log_message("info", %{
          match_id: round.match_id,
          message: "Round started"
        })
      end)
      |> Repo.transaction()

    {:ok, %Round{round | games: [game]}}
  end

  @spec complete_current_round(Match.t(), Config.t()) :: Match.t()
  def complete_current_round(match, config) do
    create_new_round = length(match.rounds) < config.rounds_per_match

    {:ok, %{round: round, next_round: next_round}} =
      match
      |> current_round()
      |> complete_round(create_new_round)

    rounds = replace_by_id(match.rounds, round)

    rounds =
      case next_round do
        nil -> rounds
        next_round -> rounds ++ [next_round]
      end

    {:ok, %Match{match | rounds: rounds}}
  end

  defp complete_round(%Round{status: "in-progress"} = round, create_new_round) do
    Multi.new()
    |> Multi.update(:round, Round.changeset(round, %{status: "complete"}))
    |> Multi.run(:log_message, fn _repo, _multi ->
      Mmoaig.Matches.create_log_message("info", %{
        match_id: round.match_id,
        message: "Round completed"
      })
    end)
    |> maybe_create_new_round(round, create_new_round)
    |> Repo.transaction()
  end

  defp maybe_create_new_round(multi, _round, false), do: Multi.put(multi, :next_round, nil)

  defp maybe_create_new_round(multi, %Round{match_id: match_id}, true) do
    Multi.insert(
      multi,
      :next_round,
      Round.changeset(%Round{}, %{match_id: match_id, status: "pending"})
    )
  end

  @spec start_current_game(Match.t()) :: Match.t()
  def start_current_game(match) do
    {:ok, game} =
      match
      |> current_game()
      |> start_game(match)

    round = current_round(match)
    games = replace_by_id(round.games, game)

    round = %{round | games: games}
    rounds = replace_by_id(match.rounds, round)

    {:ok, %Match{match | rounds: rounds}}
  end

  defp start_game(%Game{status: "pending"} = game, match) do
    {:ok, %{game: game}} =
      Multi.new()
      |> Multi.update(:game, Game.changeset(game, %{status: "in-progress"}))
      |> Multi.run(:log_message, fn _repo, _multi ->
        Mmoaig.Matches.create_log_message("info", %{
          match_id: match.id,
          message: "Game started"
        })
      end)
      |> Repo.transaction()

    {:ok, game}
  end

  @spec complete_current_game(Match.t(), Config.t()) :: Match.t()
  def complete_current_game(match, config) do
    current_round = current_round(match)
    create_new_game = length(current_round.games) < config.games_per_round

    {:ok, %{game: game, next_game: next_game}} =
      match
      |> current_game()
      |> complete_game(match.id, create_new_game)

    games = replace_by_id(current_round.games, game)

    games =
      case next_game do
        nil -> games
        next_game -> games ++ [next_game]
      end

    round = %{current_round | games: games}
    rounds = replace_by_id(match.rounds, round)

    {:ok, %Match{match | rounds: rounds}}
  end

  defp complete_game(%Game{status: "in-progress"} = game, match_id, create_new_game) do
    Multi.new()
    |> Multi.update(:game, Game.changeset(game, %{status: "complete"}))
    |> Multi.run(:log_message, fn _repo, _multi ->
      Mmoaig.Matches.create_log_message("info", %{
        match_id: match_id,
        message: "Game completed"
      })
    end)
    |> maybe_create_new_game(game, create_new_game)
    |> Repo.transaction()
  end

  defp maybe_create_new_game(multi, _game, false), do: Multi.put(multi, :next_game, nil)

  defp maybe_create_new_game(multi, %Game{round_id: round_id}, true) do
    Multi.insert(
      multi,
      :next_game,
      Game.changeset(%Game{}, %{round_id: round_id, status: "pending"})
    )
  end

  @spec current_game(Match.t()) :: Game.t() | nil
  def current_game(match) do
    case current_round(match) do
      nil -> nil
      round -> Enum.find(round.games, &(&1.status != "complete"))
    end
  end

  @spec current_round(Match.t()) :: Round.t() | nil
  def current_round(match), do: Enum.find(match.rounds, &(&1.status != "complete"))

  defp replace_by_id(haystack, %{id: needle_id} = needle) do
    Enum.map(haystack, fn
      %{id: ^needle_id} -> needle
      other -> other
    end)
  end
end
