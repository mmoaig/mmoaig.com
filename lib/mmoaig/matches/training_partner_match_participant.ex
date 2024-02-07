defmodule Mmoaig.Matches.TrainingPartnerMatchParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.TrainingPartners.TrainingPartner
  alias Mmoaig.Matches.Participant

  schema "training_partner_match_participants" do
    belongs_to :training_partner, TrainingPartner
    belongs_to :participant, Participant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(training_partner_match_participant, attrs) do
    training_partner_match_participant
    |> cast(attrs, [:training_partner_id, :participant_id])
    |> validate_required([:training_partner_id, :participant_id])
  end
end
