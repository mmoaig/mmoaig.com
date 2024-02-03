defmodule Mmoaig.MatchesFixtures do
  alias Mmoaig.EventsFixtures

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
end
