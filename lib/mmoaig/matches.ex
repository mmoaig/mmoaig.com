defmodule Mmoaig.Matches do
  import Ecto.Query, warn: false
  alias Mmoaig.Matches.LogMessage
  alias Mmoaig.Repo

  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Game
  alias Mmoaig.Matches.Turn
  alias Mmoaig.Matches.Runner
  alias Mmoaig.Matches.Updates

  def create_game(attrs) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def get_turn!(id), do: Repo.get!(Turn, id)

  def update_turn(%Turn{} = turn, attrs) do
    turn
    |> Turn.changeset(attrs)
    |> Repo.update()
  end

  def create_turn(attrs) do
    %Turn{}
    |> Turn.changeset(attrs)
    |> Repo.insert()
  end

  @spec get_current_game(atom() | %{:id => any(), optional(any()) => any()}) :: any()
  def get_current_game(match) do
    Game
    |> Game.for_match(match.id)
    |> Game.with_most_recent_first()
    |> Ecto.Query.limit(1)
    |> Repo.one()
  end

  def list_log_messages(match_id),
    do:
      LogMessage
      |> LogMessage.for_match(match_id)
      |> LogMessage.with_most_recent_first()
      |> Repo.all()

  def create_log_message("log", message),
    do:
      message
      |> Map.put(:level, "log")
      |> create_log_message()

  def create_log_message("info", message),
    do:
      message
      |> Map.put(:level, "info")
      |> create_log_message()

  def create_log_message("warning", message),
    do:
      message
      |> Map.put(:level, "warning")
      |> create_log_message()

  def create_log_message("error", message),
    do:
      message
      |> Map.put(:level, "error")
      |> create_log_message()

  defp create_log_message(message),
    do:
      %LogMessage{}
      |> LogMessage.changeset(message)
      |> Repo.insert()
      |> broadcast_log_messages()

  def list_matches do
    Repo.all(Match)
  end

  def get_match!(id), do: Repo.get!(Match, id)

  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
    |> broadcast_match_update()
  end

  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  def start_match_runner(match) do
    DynamicSupervisor.start_child(Mmoaig.Matches.Runner.Supervisor, {Runner, match})
  end

  def subscribe_to_match_updates(match_id), do: Updates.subscribe(match_id)

  defp broadcast_match_update({:ok, match}) do
    Updates.broadcast_match(match)
    {:ok, match}
  end

  defp broadcast_match_update(match), do: match

  defp broadcast_log_messages({:ok, log_message}) do
    Updates.broadcast_log_messages(log_message.match_id)
    {:ok, log_message}
  end

  defp broadcast_log_messages(error), do: error
end
