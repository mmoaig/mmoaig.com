defmodule Mmoaig.TrainingPartners.TrainingPartner do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Mmoaig.Events.Event

  schema "training_partners" do
    field :name, :string
    field :repository_url, :string
    field :enabled, :boolean, default: false
    field :slug, :string

    belongs_to :event, Event

    timestamps(type: :utc_datetime)
  end

  def changeset(training_partner, attrs) do
    training_partner
    |> cast(attrs, [:name, :repository_url, :event_id, :enabled, :slug])
    |> validate_required([:name, :repository_url, :event_id, :enabled, :slug])
    |> unique_constraint(:training_partners_slug_event_id,
      name: :training_partners_slug_event_id_index
    )
  end

  def for_event_with_slug(query, event_slug) do
    query
    |> join(:inner, [tp], e in assoc(tp, :event))
    |> where([tp, e], e.slug == ^event_slug)
  end
end
