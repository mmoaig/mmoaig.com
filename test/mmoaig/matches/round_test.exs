defmodule Mmoaig.Matches.RoundTest do
  use Mmoaig.DataCase

  alias Mmoaig.Matches.Round
  alias Mmoaig.MatchesFixtures

  test "is invalid without a status" do
    match = MatchesFixtures.match_fixture()

    refute Round.changeset(%Round{}, %{match_id: match.id}).valid?
  end

  test "is invalid with an invalid status" do
    match = MatchesFixtures.match_fixture()

    refute Round.changeset(%Round{}, %{status: "zending", match_id: match.id}).valid?
  end

  test "is invalid without a match id" do
    refute Round.changeset(%Round{}, %{status: "pending"}).valid?
  end

  test "is invalid with an invalid match id" do
    assert {:error, _changeset} =
             %Round{}
             |> Round.changeset(%{status: "pending", match_id: -1})
             |> Repo.insert()
  end

  test "is valid with an valid attributes" do
    match = MatchesFixtures.match_fixture()

    assert {:ok, _round} =
             %Round{}
             |> Round.changeset(%{status: "pending", match_id: match.id})
             |> Repo.insert()
  end
end
