defmodule Mmoaig.RockPaperScissors.Game do
  alias Mmoaig.RockPaperScissors.Turn
  alias Mmoaig.Matches.Game

  def winner(%Game{status: "complete"} = game) do
    game
    |> Map.get(:turns)
    |> group_turns_by_participant()
    |> build_turn_list()
    |> find_winning_participant_id()
    |> find_winner(game)
  end

  def winner(_), do: nil

  defp group_turns_by_participant(turns) do
    turns
    |> Enum.sort_by(& &1.inserted_at)
    |> Enum.group_by(& &1.participant_id)
  end

  defp build_turn_list(turns) do
    [first_participant_turns, second_participant_turns] = Map.values(turns)

    first_participant_turns
    |> Enum.zip(second_participant_turns)
    |> Enum.map(fn {first_turn, second_turn} -> Turn.winner(first_turn, second_turn) end)
  end

  defp find_winning_participant_id(turns) do
    turns_with_a_winner = Enum.filter(turns, &(&1 != nil))
    participants = Enum.map(turns_with_a_winner, & &1.participant_id)
    frequencies = Enum.frequencies_by(turns_with_a_winner, & &1.participant_id)

    winning_score =
      frequencies
      |> Map.values()
      |> Enum.max(fn -> nil end)

    winning_participants = Enum.filter(participants, &(frequencies[&1] == winning_score))

    case length(winning_participants) do
      1 -> Enum.at(winning_participants, 0)
      _ -> nil
    end
  end

  defp find_winner(nil, _game), do: nil

  defp find_winner(winning_participant_id, game) do
    game.turns
    |> Enum.find(&(&1.participant_id == winning_participant_id))
    |> Map.get(:participant)
  end
end
