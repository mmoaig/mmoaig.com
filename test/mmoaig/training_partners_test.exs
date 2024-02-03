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

    test "fetch_training_partner_source_code!/1 returns the source code for a training partner" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/registration.json", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"entryPoint\": \"/entry_point\"}")
      end)

      Bypass.expect(bypass, "GET", "/entry_point", fn conn ->
        Plug.Conn.resp(conn, 200, "source code")
      end)

      training_partner =
        training_partner_fixture(%{repository_url: "http://localhost:#{bypass.port}"})

      assert TrainingPartners.fetch_training_partner_source_code!(training_partner.id) ==
               "source code"
    end

    test "fetch_training_partner_source_code!/1 raises an error when the training partner can not be found" do
      assert_raise Ecto.NoResultsError, fn ->
        TrainingPartners.fetch_training_partner_source_code!(0)
      end
    end

    test "fetch_training_partner_source_code!/1 raises an error when the registration can not be fetched" do
      bypass = Bypass.open()

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 404, "Not Found")
      end)

      training_partner =
        training_partner_fixture(%{repository_url: "http://localhost:#{bypass.port}"})

      assert_raise RuntimeError, fn ->
        TrainingPartners.fetch_training_partner_source_code!(training_partner.id)
      end
    end

    test "fetch_training_partner_source_code!/1 raises an error when the source code can not be fetched" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/registration.json", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"entryPoint\": \"/entry_point\"}")
      end)

      Bypass.expect(bypass, "GET", "/entry_point", fn conn ->
        Plug.Conn.resp(conn, 404, "source code")
      end)

      training_partner =
        training_partner_fixture(%{repository_url: "http://localhost:#{bypass.port}"})

      assert_raise RuntimeError, fn ->
        TrainingPartners.fetch_training_partner_source_code!(training_partner.id)
      end
    end
  end
end
