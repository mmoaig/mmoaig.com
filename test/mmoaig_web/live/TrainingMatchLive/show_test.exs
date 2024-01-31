defmodule MmoaigWeb.TrainingMatchLive.ShowTest do
  use MmoaigWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders without crashing", %{conn: conn} do
    conn = get(conn, "/training-matches/1")
    assert html_response(conn, 200) =~ "Show!"

    {:ok, _view, html} = live(conn)
    assert html =~ "Show!"
  end
end
