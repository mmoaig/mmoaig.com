defmodule Mmoaig.TrainingMatchesTest do
  use Mmoaig.DataCase

  alias Mmoaig.TrainingMatches
  alias Mmoaig.EventsFixtures
  alias Mmoaig.TrainingPartnersFixtures

  describe "create_training_match/2" do
    test "creates a training match with valid parameters" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/registration.json", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"entryPoint\": \"/entry_point\"}")
      end)

      Bypass.expect(bypass, "GET", "/entry_point", fn conn ->
        Plug.Conn.resp(conn, 200, "source code")
      end)

      training_partner =
        TrainingPartnersFixtures.training_partner_fixture(%{
          repository_url: "http://localhost:#{bypass.port}"
        })

      event = EventsFixtures.event_fixture()

      training_match_params = %{
        training_partner_id: training_partner.id,
        trainee_file: %Plug.Upload{path: "test/support/fixtures/example_bot_file.js"}
      }

      assert {:ok,
              %{
                match: match,
                participants: {2, participants},
                training_partner_participant: training_partner_participant
              }} = TrainingMatches.create_training_match(event.slug, training_match_params)

      assert match.status == "pending"
      assert match.rated == false

      match_id = match.id

      assert [
               %{
                 id: participant_id,
                 source_code: "source code",
                 participant_number: 0,
                 match_id: ^match_id
               },
               %{source_code: "Example bot", participant_number: 1, match_id: ^match_id}
             ] = participants

      assert training_partner_participant.training_partner_id == training_partner.id
      assert training_partner_participant.participant_id == participant_id
    end

    test "returns an error with invalid parameters" do
      event = EventsFixtures.event_fixture()
      assert {:error, _change} = TrainingMatches.create_training_match(event.slug, %{})
    end

    test "raises an error with an invalid event slug" do
      training_partner = TrainingPartnersFixtures.training_partner_fixture()

      training_match_params = %{
        training_partner_id: training_partner.id,
        trainee_file: %Plug.Upload{}
      }

      assert_raise Ecto.NoResultsError, fn ->
        TrainingMatches.create_training_match("invalid-slug", training_match_params)
      end
    end

    test "raises an error when the training partner source can not be loaded" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/registration.json", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"entryPoint\": \"/entry_point\"}")
      end)

      Bypass.expect(bypass, "GET", "/entry_point", fn conn ->
        Plug.Conn.resp(conn, 500, "oops")
      end)

      training_partner =
        TrainingPartnersFixtures.training_partner_fixture(%{
          repository_url: "http://localhost:#{bypass.port}"
        })

      event = EventsFixtures.event_fixture()

      training_match_params = %{
        training_partner_id: training_partner.id,
        trainee_file: %Plug.Upload{path: "test/support/fixtures/example_bot_file.js"}
      }

      assert_raise RuntimeError, fn ->
        TrainingMatches.create_training_match(event.slug, training_match_params)
      end
    end

    test "raises an error when the trainee source can not be loaded" do
      bypass = Bypass.open()

      Bypass.expect_once(bypass, "GET", "/registration.json", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"entryPoint\": \"/entry_point\"}")
      end)

      Bypass.expect(bypass, "GET", "/entry_point", fn conn ->
        Plug.Conn.resp(conn, 200, "source code")
      end)

      training_partner =
        TrainingPartnersFixtures.training_partner_fixture(%{
          repository_url: "http://localhost:#{bypass.port}"
        })

      event = EventsFixtures.event_fixture()

      training_match_params = %{
        training_partner_id: training_partner.id,
        trainee_file: %Plug.Upload{path: "test/support/fixtures/no_file_here.js"}
      }

      assert_raise MatchError, fn ->
        TrainingMatches.create_training_match(event.slug, training_match_params)
      end
    end
  end
end
