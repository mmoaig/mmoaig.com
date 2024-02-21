defmodule Mmoaig.Matches.Round do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Game

  schema "match_rounds" do
    field :status, :string
    belongs_to :match, Match
    has_many :games, Game

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:status, :match_id])
    |> validate_required([:status, :match_id])
    |> validate_inclusion(:status, ["pending", "in-progress", "complete"])
    |> foreign_key_constraint(:match_id)
  end
end
