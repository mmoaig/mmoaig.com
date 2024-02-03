defmodule Mmoaig.TrainingPartners do
  import Ecto.Query, warn: false
  alias Mmoaig.Repo

  alias Mmoaig.TrainingPartners.TrainingPartner
  alias Mmoaig.TrainingPartners.Registration
  alias Mmoaig.TrainingPartners.SourceCode

  def list_training_partners_for_event(event_slug) do
    TrainingPartner
    |> TrainingPartner.for_event_with_slug(event_slug)
    |> Repo.all()
  end

  def fetch_training_partner_source_code!(training_partner_id) do
    TrainingPartner
    |> Repo.get!(training_partner_id)
    |> Registration.fetch_registration_for_training_partner!()
    |> SourceCode.fetch_source_code_for_registration!()
  end
end
