defmodule MmoaigWeb.TrainingMatchLive.ShowTest do
  use MmoaigWeb.ConnCase
  import Phoenix.LiveViewTest

  alias Mmoaig.MatchesFixtures
  alias Mmoaig.Matches

  test "renders without crashing", %{conn: conn} do
    match = MatchesFixtures.match_fixture()
    conn = get(conn, "/training-matches/#{match.id}")

    assert html_response(conn, 200) =~ "Show!"
    assert html_response(conn, 200) =~ match.status

    {:ok, _view, html} = live(conn)
    assert html =~ "Show!"
  end

  test "updates the match status when it changes", %{conn: conn} do
    match = MatchesFixtures.match_fixture()
    conn = get(conn, "/training-matches/#{match.id}")
    {:ok, view, _html} = live(conn)
    Matches.update_match(match, %{status: "in-progress"})
    assert render(view) =~ "in-progress"
  end

  test "updates the log messages when they change", %{conn: conn} do
    match = MatchesFixtures.match_fixture()
    conn = get(conn, "/training-matches/#{match.id}")
    {:ok, view, _html} = live(conn)
    Matches.create_log_message("log", %{match_id: match.id, message: "some log message"})
    assert render(view) =~ "some log message"
  end
end
