defmodule Mmoaig.Matches.TurnTest do
  use Mmoaig.DataCase

  alias Mmoaig.MatchesFixtures
  alias Mmoaig.Matches.Turn

  test "is invalid without a status" do
    game = MatchesFixtures.game_fixture()
    participant = MatchesFixtures.participant_fixture()

    refute Turn.changeset(%Turn{}, %{
             participant_id: participant.id,
             game_id: game.id
           }).valid?
  end

  test "is invalid with an invalid status" do
    game = MatchesFixtures.game_fixture()
    participant = MatchesFixtures.participant_fixture()

    refute Turn.changeset(%Turn{}, %{
             participant_id: participant.id,
             status: "zending",
             game_id: game.id
           }).valid?
  end

  test "is invalid without a participant id" do
    game = MatchesFixtures.game_fixture()

    refute Turn.changeset(%Turn{}, %{status: "pending", game_id: game.id}).valid?
  end

  test "is invalid with an invalid participant id" do
    game = MatchesFixtures.game_fixture()

    assert {:error, _changeset} =
             %Turn{}
             |> Turn.changeset(%{
               status: "pending",
               participant_id: -1,
               game_id: game.id
             })
             |> Repo.insert()
  end

  test "is invalid without a game id" do
    participant = MatchesFixtures.participant_fixture()

    refute Turn.changeset(%Turn{}, %{
             status: "pending",
             participant_id: participant.id
           }).valid?
  end

  test "is invalid with an invalid game id" do
    participant = MatchesFixtures.participant_fixture()

    assert {:error, _changeset} =
             %Turn{}
             |> Turn.changeset(%{
               status: "pending",
               participant_id: participant.id,
               game_id: -1
             })
             |> Repo.insert()
  end

  test "is valid with an valid attributes" do
    game = MatchesFixtures.game_fixture()
    participant = MatchesFixtures.participant_fixture()

    assert {:ok, _turn} =
             %Turn{}
             |> Turn.changeset(%{
               status: "pending",
               participant_id: participant.id,
               game_id: game.id
             })
             |> Repo.insert()
  end
end
