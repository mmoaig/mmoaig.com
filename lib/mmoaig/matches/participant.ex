defmodule Mmoaig.Matches.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.TrainingPartnerMatchParticipant

  schema "match_participants" do
    field :source_code, :string
    field :participant_number, :integer

    belongs_to :match, Match
    has_many :training_partner_match_participants, TrainingPartnerMatchParticipant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:source_code, :match_id, :participant_number])
    |> validate_required([:source_code, :match_id, :participant_number])
    |> validate_number(:participant_number, greater_than: -1)
    |> unique_constraint([:participant_number, :match_id],
      name: "match_participants_match_id_participant_number_index"
    )
  end
end
