defmodule Mmoaig.Events.EventTest do
  use Mmoaig.DataCase

  alias Mmoaig.Events.Event
  alias Mmoaig.Repo

  describe "changeset" do
    test "is valid with valid attributes" do
      attrs = %{name: "some name", slug: "some slug", enabled: true}
      assert Event.changeset(%Event{}, attrs).valid?

      assert {:ok, event} =
               %Event{}
               |> Event.changeset(attrs)
               |> Repo.insert()

      assert event.name == attrs[:name]
      assert event.slug == attrs[:slug]
      assert event.enabled == attrs[:enabled]
    end

    test "is invalid without a name" do
      attrs = %{slug: "some slug", enabled: true}
      refute Event.changeset(%Event{}, attrs).valid?
    end

    test "is invalid without a slug" do
      attrs = %{name: "some name", enabled: true}
      refute Event.changeset(%Event{}, attrs).valid?
    end

    test "is valid without the enabled flag" do
      attrs = %{name: "some name", slug: "some slug"}
      assert Event.changeset(%Event{}, attrs).valid?

      assert {:ok, event} =
               %Event{}
               |> Event.changeset(attrs)
               |> Repo.insert()

      assert event.name == attrs[:name]
      assert event.slug == attrs[:slug]
      assert event.enabled == false
    end

    test "is invalid with a slug which is already in the database" do
      attrs = %{name: "some name", slug: "some slug", enabled: true}
      assert Event.changeset(%Event{}, attrs).valid?

      assert {:ok, _event} =
               %Event{}
               |> Event.changeset(attrs)
               |> Repo.insert()

      attrs = %{name: "some other name", slug: "some slug", enabled: true}
      assert Event.changeset(%Event{}, attrs).valid?

      assert {:error, _changeset} =
               %Event{}
               |> Event.changeset(attrs)
               |> Repo.insert()
    end
  end
end
