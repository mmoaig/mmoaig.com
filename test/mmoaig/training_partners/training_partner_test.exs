defmodule Mmoaig.TrainingPartners.TrainingPartnerTest do
  use Mmoaig.DataCase

  alias Mmoaig.TrainingPartners.TrainingPartner
  alias Mmoaig.Repo

  alias Mmoaig.EventsFixtures

  describe "changeset" do
    test "is valid with valid attributes" do
      event =
        EventsFixtures.event_fixture()

      assert TrainingPartner.changeset(%TrainingPartner{}, %{
               name: "some name",
               repository_url: "some repository_url",
               event_id: event.id,
               slug: "some slug"
             }).valid?
    end

    test "is invalid without a name" do
      event =
        EventsFixtures.event_fixture()

      refute TrainingPartner.changeset(%TrainingPartner{}, %{
               repository_url: "some repository_url",
               event_id: event.id,
               slug: "some slug"
             }).valid?
    end

    test "is invalid without a repository_url" do
      event =
        EventsFixtures.event_fixture()

      refute TrainingPartner.changeset(%TrainingPartner{}, %{
               name: "some name",
               event_id: event.id,
               slug: "some slug"
             }).valid?
    end

    test "is invalid without an event_id" do
      refute TrainingPartner.changeset(%TrainingPartner{}, %{
               name: "some name",
               repository_url: "some repository_url",
               slug: "some slug"
             }).valid?
    end

    test "is invalid with an invalid event_id" do
      assert {:error, _changeset} =
               %TrainingPartner{}
               |> TrainingPartner.changeset(%{
                 name: "some name",
                 repository_url: "some repository_url",
                 event_id: Ecto.UUID.generate(),
                 slug: "some slug"
               })
               |> Repo.insert()
    end

    test "is invalid without a slug" do
      event =
        EventsFixtures.event_fixture()

      refute TrainingPartner.changeset(%TrainingPartner{}, %{
               name: "some name",
               repository_url: "some repository_url",
               event_id: event.id
             }).valid?
    end

    test "is invalid a duplicate slug for the same event_id" do
      event =
        EventsFixtures.event_fixture()

      {:ok, _training_partner} =
        %TrainingPartner{}
        |> TrainingPartner.changeset(%{
          name: "some name",
          repository_url: "some repository_url",
          event_id: event.id,
          slug: "some slug"
        })
        |> Repo.insert()

      assert {:error, _changeset} =
               %TrainingPartner{}
               |> TrainingPartner.changeset(%{
                 name: "some name",
                 repository_url: "some repository_url",
                 event_id: event.id,
                 slug: "some slug"
               })
               |> Repo.insert()
    end
  end
end
