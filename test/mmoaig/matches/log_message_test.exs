defmodule Mmoaig.Matches.LogMessageTest do
  use Mmoaig.DataCase

  alias Mmoaig.Matches.LogMessage
  alias Mmoaig.MatchesFixtures
  alias Mmoaig.Repo

  test "is valid with valid attributes" do
    match = MatchesFixtures.match_fixture()

    assert LogMessage.changeset(%LogMessage{}, %{
             level: "info",
             message: "some message",
             match_id: match.id
           }).valid?
  end

  test "is invalid without a level" do
    match = MatchesFixtures.match_fixture()

    refute LogMessage.changeset(%LogMessage{}, %{
             message: "some message",
             match_id: match.id
           }).valid?
  end

  test "is invalid with an invalid level" do
    match = MatchesFixtures.match_fixture()

    refute LogMessage.changeset(%LogMessage{}, %{
             level: "beans",
             message: "some message",
             match_id: match.id
           }).valid?
  end

  test "is invalid without a message" do
    match = MatchesFixtures.match_fixture()

    refute LogMessage.changeset(%LogMessage{}, %{
             level: "beans",
             match_id: match.id
           }).valid?
  end

  test "is invalid without a match" do
    refute LogMessage.changeset(%LogMessage{}, %{
             level: "beans",
             message: "message"
           }).valid?
  end

  test "is invalid without a valid match" do
    assert {:error, _changeset} =
             %LogMessage{}
             |> LogMessage.changeset(%{
               level: "beans",
               message: "message",
               match_id: -1
             })
             |> Repo.insert()
  end

  test "is invalid without a valid participant" do
    match = MatchesFixtures.match_fixture()

    assert {:error, _changeset} =
             %LogMessage{}
             |> LogMessage.changeset(%{
               level: "beans",
               message: "message",
               match_id: match.id,
               participant_id: -1
             })
             |> Repo.insert()
  end
end
