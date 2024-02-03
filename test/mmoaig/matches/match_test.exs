defmodule Mmoaig.Matches.MatchTest do
  use Mmoaig.DataCase

  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches
  alias Mmoaig.EventsFixtures

  test "is invalid without a status" do
    event = EventsFixtures.event_fixture()

    refute Matches.change_match(%Match{}, %{
             event_id: event.id,
             rated: true,
             runner_token: "some runner_token"
           }).valid?
  end

  test "is invalid with an invalid status" do
    event = EventsFixtures.event_fixture()

    refute Matches.change_match(%Match{}, %{
             event_id: event.id,
             status: "not a status",
             rated: true,
             runner_token: "some runner_token"
           }).valid?
  end

  test "is invalid without a runner token" do
    event = EventsFixtures.event_fixture()

    refute Matches.change_match(%Match{}, %{
             event_id: event.id,
             status: "not a status",
             rated: true
           }).valid?
  end

  test "is invalid without an event id" do
    refute Matches.change_match(%Match{}, %{
             runner_token: "runner token",
             status: "not a status",
             rated: true
           }).valid?
  end

  test "is invalid with an invalid event id" do
    assert {:error, _changeset} =
             Matches.create_match(%{
               event_id: Ecto.UUID.generate(),
               rated: true,
               status: "pending",
               runner_token: "some runner_token"
             })
  end

  test "is valid with an valid attributes" do
    event = EventsFixtures.event_fixture()

    assert {:ok, _match} =
             Matches.create_match(%{
               event_id: event.id,
               rated: true,
               status: "pending",
               runner_token: "some runner_token"
             })
  end
end
