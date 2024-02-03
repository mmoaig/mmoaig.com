defmodule Mmoaig.TrainingPartners.RegistrationTest do
  use Mmoaig.DataCase

  alias Mmoaig.TrainingPartners.TrainingPartner
  alias Mmoaig.TrainingPartners.Registration

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "raises an error when the registration can not be fetched", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 404, "Not Found")
    end)

    training_partner = %TrainingPartner{repository_url: "http://localhost:#{bypass.port}"}

    assert_raise RuntimeError, fn ->
      Registration.fetch_registration_for_training_partner!(training_partner)
    end
  end

  test "raises an error when the registration is invalid JSON", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, "Not JSON")
    end)

    training_partner = %TrainingPartner{repository_url: "http://localhost:#{bypass.port}"}

    assert_raise Jason.DecodeError, fn ->
      Registration.fetch_registration_for_training_partner!(training_partner)
    end
  end

  test "raises an error when the registration does not contain an entry point", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, "{}")
    end)

    training_partner = %TrainingPartner{repository_url: "http://localhost:#{bypass.port}"}

    assert_raise MatchError, fn ->
      Registration.fetch_registration_for_training_partner!(training_partner)
    end
  end

  test "returns the registration for a training partner", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, "{\"entryPoint\": \"entry_point\"}")
    end)

    training_partner = %TrainingPartner{repository_url: "http://localhost:#{bypass.port}"}
    registration = Registration.fetch_registration_for_training_partner!(training_partner)

    assert registration.repository_url == training_partner.repository_url
    assert registration.entry_point == "entry_point"
  end
end
