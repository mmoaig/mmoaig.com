defmodule Mmoaig.Matches.Turn do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.Matches.Game
  alias Mmoaig.Matches.Participant

  schema "match_turns" do
    field :status, :string
    field :turn, :map

    belongs_to :game, Game
    belongs_to :participant, Participant

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(turn, attrs) do
    turn
    |> cast(attrs, [:turn, :status, :participant_id, :game_id])
    |> validate_required([:status, :participant_id, :game_id])
    |> validate_inclusion(:status, ["pending", "in-progress", "complete"])
    |> foreign_key_constraint(:participant_id)
    |> foreign_key_constraint(:game_id)
  end
end
