defmodule Mmoaig.Matches.TrainingPartnerParticipantTest do
  use Mmoaig.DataCase

  alias Mmoaig.Repo
  alias Mmoaig.MatchesFixtures
  alias Mmoaig.TrainingPartnersFixtures
  alias Mmoaig.Matches.TrainingPartnerMatchParticipant

  test "is valid with valid attributes" do
    participant =
      MatchesFixtures.participant_fixture()

    training_partner =
      TrainingPartnersFixtures.training_partner_fixture()

    assert TrainingPartnerMatchParticipant.changeset(%TrainingPartnerMatchParticipant{}, %{
             training_partner_id: training_partner.id,
             participant_id: participant.id
           }).valid?
  end

  test "is invalid without a training partner" do
    participant =
      MatchesFixtures.participant_fixture()

    refute TrainingPartnerMatchParticipant.changeset(%TrainingPartnerMatchParticipant{}, %{
             participant_id: participant.id
           }).valid?
  end

  test "is invalid with an invalid training partner" do
    participant =
      MatchesFixtures.participant_fixture()

    assert {:error, _changeset} =
             %TrainingPartnerMatchParticipant{}
             |> TrainingPartnerMatchParticipant.changeset(%{
               participant_id: participant.id,
               trainint_partner_id: Ecto.UUID.generate()
             })
             |> Repo.insert()
  end

  test "is invalid without a participant" do
    training_partner =
      TrainingPartnersFixtures.training_partner_fixture()

    refute TrainingPartnerMatchParticipant.changeset(%TrainingPartnerMatchParticipant{}, %{
             training_partner_id: training_partner.id
           }).valid?
  end

  test "is invalid with an invalid participant" do
    training_partner =
      TrainingPartnersFixtures.training_partner_fixture()

    assert {:error, _changeset} =
             %TrainingPartnerMatchParticipant{}
             |> TrainingPartnerMatchParticipant.changeset(%{
               training_partner_id: training_partner.id
             })
             |> Repo.insert()
  end
end
