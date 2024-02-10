defmodule Mmoaig.Matches do
  import Ecto.Query, warn: false
  alias Mmoaig.Matches.LogMessage
  alias Mmoaig.Repo

  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Runner
  alias Mmoaig.Matches.Updates

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

  def start_runner(match) do
    DynamicSupervisor.start_child(Mmoaig.Matches.Runner.Supervisor, {Runner, match})
  end

  def subscribe_to_match_updates(match_id), do: Updates.subscribe(match_id)

  defp broadcast_match_update({:ok, match}) do
    Updates.broadcast(match)
    {:ok, match}
  end

  defp broadcast_match_update(match), do: match
end
