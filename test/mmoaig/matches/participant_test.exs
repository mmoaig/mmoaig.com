defmodule Mmoaig.Matches.ParticipantTest do
  use Mmoaig.DataCase

  alias Mmoaig.MatchesFixtures
  alias Mmoaig.Matches.Participant
  alias Mmoaig.Repo

  test "is valid with valid attributes" do
    match = MatchesFixtures.match_fixture()

    assert Participant.changeset(%Participant{}, %{
             participant_number: 1,
             match_id: match.id,
             source_code: "some source code"
           }).valid?
  end

  test "is invalid without a participant number" do
    match = MatchesFixtures.match_fixture()

    refute Participant.changeset(%Participant{}, %{
             match_id: match.id,
             source_code: "some source code"
           }).valid?
  end

  test "is invalid with a negative participant number" do
    match = MatchesFixtures.match_fixture()

    refute Participant.changeset(%Participant{}, %{
             participant_number: -1,
             match_id: match.id,
             source_code: "some source code"
           }).valid?
  end

  test "is invalid with a duplicated participant number" do
    match = MatchesFixtures.match_fixture()

    {:ok, _participant} =
      %Participant{}
      |> Participant.changeset(%{
        participant_number: 1,
        match_id: match.id,
        source_code: "some source code"
      })
      |> Repo.insert()

    assert {:error, _changeset} =
             %Participant{}
             |> Participant.changeset(%{
               participant_number: 1,
               match_id: match.id,
               source_code: "some other source code"
             })
             |> Repo.insert()
  end

  test "is invalid without a match" do
    refute Participant.changeset(%Participant{}, %{
             participant_number: 1,
             source_code: "some source code"
           }).valid?
  end

  test "is invalid with an invalid match" do
    assert {:error, _changeset} =
             %Participant{}
             |> Participant.changeset(%{
               participant_number: 1,
               match_id: Ecto.UUID.generate(),
               source_code: "some source code"
             })
             |> Repo.insert()
  end
end
