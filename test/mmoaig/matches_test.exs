defmodule Mmoaig.MatchesTest do
  use Mmoaig.DataCase

  alias Mmoaig.Matches

  describe "matches" do
    alias Mmoaig.Matches.Match
    alias Mmoaig.Matches.LogMessage

    import Mmoaig.MatchesFixtures
    alias Mmoaig.EventsFixtures

    @invalid_attrs %{status: "pending", rated: nil, runner_token: nil}

    test "create_log_message/2 with valid data creates a log message" do
      match = match_fixture()

      assert {:ok, %LogMessage{level: "log", message: "some log message"}} =
               Matches.create_log_message("log", %{
                 match_id: match.id,
                 message: "some log message"
               })

      assert {:ok, %LogMessage{level: "info", message: "some info message"}} =
               Matches.create_log_message("info", %{
                 match_id: match.id,
                 message: "some info message"
               })

      assert {:ok, %LogMessage{level: "warning", message: "some warning message"}} =
               Matches.create_log_message("warning", %{
                 match_id: match.id,
                 message: "some warning message"
               })

      assert {:ok, %LogMessage{level: "error", message: "some error message"}} =
               Matches.create_log_message("error", %{
                 match_id: match.id,
                 message: "some error message"
               })
    end

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Matches.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Matches.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = %{
        status: "pending",
        rated: true,
        runner_token: "some runner_token",
        event_id: EventsFixtures.event_fixture().id
      }

      assert {:ok, %Match{} = match} = Matches.create_match(valid_attrs)
      assert match.status == "pending"
      assert match.rated == true
      assert match.runner_token == "some runner_token"
      assert match.event_id == valid_attrs.event_id
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()

      Matches.subscribe_to_match_updates(match.id)

      update_attrs = %{
        status: "in-progress",
        rated: false,
        runner_token: "some updated runner_token"
      }

      assert {:ok, %Match{} = match} = Matches.update_match(match, update_attrs)
      assert match.status == "in-progress"
      assert match.rated == false
      assert match.runner_token == "some updated runner_token"

      assert_received {:match_updated, ^match}
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      Matches.subscribe_to_match_updates(match.id)
      assert {:error, %Ecto.Changeset{}} = Matches.update_match(match, @invalid_attrs)
      assert match == Matches.get_match!(match.id)
      refute_received _match
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Matches.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Matches.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Matches.change_match(match)
    end
  end
end
