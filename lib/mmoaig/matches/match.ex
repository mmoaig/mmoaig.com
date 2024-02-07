defmodule Mmoaig.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.Matches.Participant

  schema "matches" do
    field :status, :string
    field :rated, :boolean, default: false
    field :runner_token, :string
    field :event_id, :id

    has_many :participants, Participant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:status, :rated, :runner_token, :event_id])
    |> validate_required([:status, :rated, :runner_token, :event_id])
    |> validate_inclusion(:status, ["pending", "in-progress", "complete"])
    |> foreign_key_constraint(:event_id)
  end
end
