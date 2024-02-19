defmodule Mmoaig.Matches.Game do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mmoaig.Matches.Round
  alias Mmoaig.Matches.Turn

  schema "match_games" do
    field :status, :string
    belongs_to :round, Round
    has_many :turns, Turn

    timestamps(type: :utc_datetime)
  end

  def for_match(query, match_id) do
    query
    |> join(:inner, [g], r in assoc(g, :round))
    |> where([g, r], r.match_id == ^match_id)
  end

  def with_most_recent_first(query) do
    query
    |> order_by([g], desc: g.inserted_at)
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
