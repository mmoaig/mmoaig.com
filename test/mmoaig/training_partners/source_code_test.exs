defmodule Mmoaig.TrainingPartners.SourceCodeTest do
  use Mmoaig.DataCase

  alias Mmoaig.TrainingPartners.Registration
  alias Mmoaig.TrainingPartners.SourceCode

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "raises an error when the source can not be fetched", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 404, "Not Found")
    end)

    registration = %Registration{
      repository_url: "http://localhost:#{bypass.port}",
      entry_point: "/entry_point"
    }

    assert_raise RuntimeError, fn ->
      SourceCode.fetch_source_code_for_registration!(registration)
    end
  end

  test "returns the source code for a registration", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, "Source Code")
    end)

    registration = %Registration{
      repository_url: "http://localhost:#{bypass.port}",
      entry_point: "/entry_point"
    }

    assert SourceCode.fetch_source_code_for_registration!(registration) == "Source Code"
  end
end
