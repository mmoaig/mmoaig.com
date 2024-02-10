defmodule Mmoaig.Matches.LogMessage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Participant

  schema "match_log_messages" do
    field :level, :string
    field :message, :string

    belongs_to :match, Match
    belongs_to :participant, Participant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(log_message, attrs) do
    log_message
    |> cast(attrs, [:level, :message, :match_id, :participant_id])
    |> validate_required([:level, :message, :match_id])
    |> validate_inclusion(:level, ["log", "info", "warning", "error"])
  end
end
