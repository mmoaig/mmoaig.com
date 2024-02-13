defmodule Mmoaig.MatchesFixtures do
  alias Mmoaig.Matches.LogMessage
  alias Mmoaig.Matches.Round
  alias Mmoaig.Matches.Game
  alias Mmoaig.EventsFixtures
  alias Mmoaig.Repo
  alias Mmoaig.Matches.Participant

  def match_fixture(attrs \\ %{}) do
    event_id =
      with %{event_id: event_id} <- attrs do
        event_id
      else
        _ ->
          event = EventsFixtures.event_fixture()
          event.id
      end

    {:ok, match} =
      attrs
      |> Enum.into(%{
        rated: true,
        runner_token: "some runner_token",
        status: "pending",
        event_id: event_id
      })
      |> Mmoaig.Matches.create_match()

    match
  end

  def participant_fixture(attrs \\ %{}) do
    match_id =
      with %{match_id: match_id} <- attrs do
        match_id
      else
        _ ->
          match = match_fixture()
          match.id
      end

    attrs =
      Enum.into(attrs, %{
        participant_number: 1,
        match_id: match_id,
        source_code: "some source code"
      })

    {:ok, participant} =
      %Participant{}
      |> Participant.changeset(attrs)
      |> Repo.insert()

    participant
  end

  def log_message_fixture(attrs \\ %{}) do
    match_id =
      with %{match_id: match_id} <- attrs do
        match_id
      else
        _ ->
          match = match_fixture()
          match.id
      end

    attrs =
      Enum.into(attrs, %{
        match_id: match_id,
        level: "log",
        message: "some log message"
      })

    {:ok, log_message} =
      %LogMessage{}
      |> LogMessage.changeset(attrs)
      |> Repo.insert()

    log_message
  end

  def round_fixture(attrs \\ %{}) do
    match_id =
      with %{match_id: match_id} <- attrs do
        match_id
      else
        _ ->
          match = match_fixture()
          match.id
      end

    attrs =
      Enum.into(attrs, %{
        match_id: match_id,
        status: "pending"
      })

    {:ok, round} =
      %Round{}
      |> Round.changeset(attrs)
      |> Repo.insert()

    round
  end

  def game_fixture(attrs \\ %{}) do
    round_id =
      with %{round_id: round_id} <- attrs do
        round_id
      else
        _ ->
          round = round_fixture()
          round.id
      end

    attrs =
      Enum.into(attrs, %{
        round_id: round_id,
        status: "pending"
      })

    {:ok, game} =
      %Game{}
      |> Game.changeset(attrs)
      |> Repo.insert()

    game
  end

  def turn_fixture(attrs \\ %{}) do
    game_id =
      with %{game_id: game_id} <- attrs do
        game_id
      else
        _ ->
          game_fixture().id
      end

    participant_id =
      with %{participant_id: participant_id} <- attrs do
        participant_id
      else
        _ ->
          match = match_fixture()
          participant = participant_fixture(match_id: match.id)
          participant.id
      end

    {:ok, turn} =
      Mmoaig.Matches.create_turn(%{
        game_id: game_id,
        participant_id: participant_id,
        status: "pending"
      })

    turn
  end
end
