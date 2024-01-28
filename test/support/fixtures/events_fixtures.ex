defmodule Mmoaig.EventsFixtures do
  alias Mmoaig.Repo
  alias Mmoaig.Events.Event

  def event_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        enabled: true,
        name: "some name",
        slug: "some slug"
      })

    {:ok, event} =
      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert()

    event
  end
end
