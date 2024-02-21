defmodule Mmoaig.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :enabled, :boolean, default: false
    field :name, :string
    field :slug, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :enabled, :slug])
    |> validate_required([:name, :enabled, :slug])
    |> unique_constraint(:slug)
  end

  @spec game_logic(Mmoaig.Matches.Event.t()) :: Mmoaig.GameLogic.t()
  def game_logic(event) do
    case event.slug do
      "rock-paper-scissors" -> Mmoaig.RockPaperScissors
    end
  end
end
