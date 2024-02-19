defmodule Mmoaig.RockPaperScissors.Turn do
  alias Mmoaig.Matches.Turn

  def build_turn_map("rock"), do: %{turn: "rock"}
  def build_turn_map("paper"), do: %{turn: "paper"}
  def build_turn_map("scissors"), do: %{turn: "scissors"}

  def winner(
        %Turn{turn: first_turn, status: "complete"} = first_participant_turn,
        %Turn{turn: second_turn, status: "complete"} = second_participant_turn
      ) do
    case raw_winner(get_turn_from_map(first_turn), get_turn_from_map(second_turn)) do
      :first_participant -> first_participant_turn
      :second_participant -> second_participant_turn
      :tie -> nil
    end
  end

  def winner(_, _), do: nil

  defp get_turn_from_map(%{turn: turn}), do: turn

  defp raw_winner("rock", "scissors"), do: :first_participant
  defp raw_winner("scissors", "rock"), do: :second_participant

  defp raw_winner("paper", "rock"), do: :first_participant
  defp raw_winner("rock", "paper"), do: :second_participant

  defp raw_winner("scissors", "paper"), do: :first_participant
  defp raw_winner("paper", "scissors"), do: :second_participant

  defp raw_winner(_, _), do: :tie
end
