defmodule Mmoaig.EventsTest do
  use Mmoaig.DataCase

  alias Mmoaig.Events

  describe "events" do
    import Mmoaig.EventsFixtures

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end
  end
end
