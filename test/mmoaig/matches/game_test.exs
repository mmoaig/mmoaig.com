defmodule Mmoaig.Matches.GameTest do
  use Mmoaig.DataCase

  alias Mmoaig.MatchesFixtures
  alias Mmoaig.Matches.Game

  test "is invalid without a status" do
    round = MatchesFixtures.round_fixture()

    refute Game.changeset(%Game{}, %{status: "zending", round_id: round.id}).valid?
  end

  test "is invalid with an invalid status" do
    round = MatchesFixtures.round_fixture()

    refute Game.changeset(%Game{}, %{status: "zending", round_id: round.id}).valid?
  end

  test "is invalid without a round id" do
    refute Game.changeset(%Game{}, %{status: "pending"}).valid?
  end

  test "is invalid with an invalid round id" do
    assert {:error, _changeset} =
             %Game{}
             |> Game.changeset(%{status: "pending", round_id: -1})
             |> Repo.insert()
  end

  test "is valid with an valid attributes" do
    round = MatchesFixtures.round_fixture()

    assert {:ok, _game} =
             %Game{}
             |> Game.changeset(%{status: "pending", round_id: round.id})
             |> Repo.insert()
  end
end
