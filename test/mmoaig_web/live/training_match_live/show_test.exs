defmodule MmoaigWeb.TrainingMatchLive.ShowTest do
  use MmoaigWeb.ConnCase
  import Phoenix.LiveViewTest

  alias Mmoaig.MatchesFixtures

  test "renders without crashing", %{conn: conn} do
    match = MatchesFixtures.match_fixture()
    conn = get(conn, "/training-matches/#{match.id}")

    assert html_response(conn, 200) =~ "Show!"
    assert html_response(conn, 200) =~ match.status

    {:ok, _view, html} = live(conn)
    assert html =~ "Show!"
  end
end
