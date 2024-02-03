defmodule Mmoaig.TrainingPartners do
  import Ecto.Query, warn: false
  alias Mmoaig.Repo

  alias Mmoaig.TrainingPartners.TrainingPartner

  def list_training_partners_for_event(event_slug) do
    TrainingPartner
    |> TrainingPartner.for_event_with_slug(event_slug)
    |> Repo.all()
  end
end
