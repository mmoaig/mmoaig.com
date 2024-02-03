defmodule Mmoaig.TrainingPartnersFixtures do
  alias Mmoaig.TrainingPartners.TrainingPartner
  alias Mmoaig.Repo
  alias Mmoaig.EventsFixtures

  def training_partner_fixture(attrs \\ %{}) do
    event_id =
      with %{event_id: event_id} <- attrs do
        event_id
      else
        _ ->
          event = EventsFixtures.event_fixture()
          event.id
      end

    attrs =
      attrs
      |> Enum.into(%{
        name: "some name",
        repository_url: "some repository_url",
        slug: "some slug",
        event_id: event_id
      })

    {:ok, training_partner} =
      %TrainingPartner{}
      |> TrainingPartner.changeset(attrs)
      |> Repo.insert()

    training_partner
  end
end
