defmodule Mmoaig.EventsTest do
  use Mmoaig.DataCase

  alias Mmoaig.Events

  describe "events" do
    import Mmoaig.EventsFixtures

    test "game_logic/1 returns the correct game logic module" do
      event = event_fixture(%{slug: "rock-paper-scissors"})
      assert Mmoaig.RockPaperScissors == Events.game_logic(event)
    end

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "find_event_by_slug!/1 returns the event when found" do
      event = event_fixture()
      assert event == Events.find_event_by_slug!(event.slug)
    end

    test "find_event_by_slug!/1 raises an error when event is not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Events.find_event_by_slug!("non-existent-event")
      end
    end
  end
end
