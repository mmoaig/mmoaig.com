defmodule Mmoaig.TrainingPartnersTest do
  use Mmoaig.DataCase

  alias Mmoaig.TrainingPartners

  describe "training_partners" do
    import Mmoaig.TrainingPartnersFixtures
    alias Mmoaig.EventsFixtures

    test "list_training_partners_for_event/1 returns all training_partners for the given event slug" do
      event = EventsFixtures.event_fixture()
      other_event = EventsFixtures.event_fixture(%{slug: "other-slug"})

      training_partner = training_partner_fixture(%{event_id: event.id})
      training_partner_fixture(%{event_id: other_event.id})

      assert [training_partner] == TrainingPartners.list_training_partners_for_event(event.slug)
    end
  end
end
