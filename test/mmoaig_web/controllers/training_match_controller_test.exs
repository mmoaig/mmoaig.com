defmodule MmoaigWeb.TrainingMatchControllerTest do
  use MmoaigWeb.ConnCase

  alias Mmoaig.EventsFixtures
  alias Mmoaig.TrainingPartnersFixtures

  describe "new/2" do
    test "renders the new training match form", %{conn: conn} do
      conn = get(conn, ~p"/events/rock-paper-scissors/training-matches/new")
      assert html_response(conn, 200) =~ "Create A Training Match"
    end
  end

  describe "create" do
    test "shows errors when the training match is invalid", %{conn: conn} do
      event = EventsFixtures.event_fixture()

      assert conn
             |> post(~p"/events/#{event.slug}/training-matches/create", %{
               "training_match_params" => %{}
             })
             |> html_response(200) =~ "can&#39;t be blank"
    end

    test "creates a training match when the training match is valid", %{conn: conn} do
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

      assert conn
             |> post(~p"/events/#{event.slug}/training-matches/create", %{
               "training_match_params" => training_match_params
             })
             |> html_response(302) =~ "You are being"
    end
  end
end
