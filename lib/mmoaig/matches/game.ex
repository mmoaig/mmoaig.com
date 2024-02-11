defmodule Mmoaig.Matches.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.Matches.Round

  schema "match_games" do
    field :status, :string
    belongs_to :round, Round

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:status, :round_id])
    |> validate_required([:status, :round_id])
    |> validate_inclusion(:status, ["pending", "in-progress", "complete"])
    |> foreign_key_constraint(:round_id)
  end
end
