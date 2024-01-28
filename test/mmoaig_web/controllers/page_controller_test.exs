defmodule MmoaigWeb.PageControllerTest do
  use MmoaigWeb.ConnCase

  alias Mmoaig.EventsFixtures

  test "GET /", %{conn: conn} do
    event = EventsFixtures.event_fixture()
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~ "MMOAIG"
    assert html_response(conn, 200) =~ event.name
  end
end
