defmodule Mmoaig.TrainingMatches.TrainingMatchTest do
  use Mmoaig.DataCase

  alias Mmoaig.TrainingMatches.TrainingMatch
  alias Mmoaig.TrainingPartnersFixtures

  test "is valid with valid attributes" do
    training_partner = TrainingPartnersFixtures.training_partner_fixture()

    training_match =
      %TrainingMatch{}
      |> TrainingMatch.changeset(%{
        training_partner_id: training_partner.id,
        trainee_file: "trainee_file"
      })

    assert training_match.valid?
  end

  test "is invalid without a training partner" do
    training_match =
      %TrainingMatch{}
      |> TrainingMatch.changeset(%{
        trainee_file: "trainee_file"
      })

    refute training_match.valid?
  end

  test "is invalid with an invalid training partner" do
    training_match =
      %TrainingMatch{}
      |> TrainingMatch.changeset(%{
        trainee_file: "trainee_file",
        training_partner_id: -1
      })

    refute training_match.valid?
  end

  test "is invalid without a trainee file" do
    training_partner = TrainingPartnersFixtures.training_partner_fixture()

    training_match =
      %TrainingMatch{}
      |> TrainingMatch.changeset(%{
        training_partner_id: training_partner.id
      })

    refute training_match.valid?
  end
end
