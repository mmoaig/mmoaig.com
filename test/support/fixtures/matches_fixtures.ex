defmodule Mmoaig.MatchesFixtures do
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
end
