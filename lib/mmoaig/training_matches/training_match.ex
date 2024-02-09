defmodule Mmoaig.TrainingMatches.TrainingMatch do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.Repo
  alias Mmoaig.TrainingPartners.TrainingPartner

  embedded_schema do
    field :training_partner_id, :integer
    field :trainee_file, :any, virtual: true
  end

  @doc false
  def changeset(training_match, attrs) do
    training_match
    |> cast(attrs, [:training_partner_id, :trainee_file])
    |> validate_required([:training_partner_id, :trainee_file])
    |> validate_existing_training_partner
  end

  defp validate_existing_training_partner(changeset) do
    training_partner_id = get_field(changeset, :training_partner_id)

    case get_training_partner(training_partner_id) do
      nil -> add_error(changeset, :training_partner_id, "does not exist")
      _ -> changeset
    end
  end

  defp get_training_partner(nil), do: %{}

  defp get_training_partner(training_partner_id) do
    Repo.get(TrainingPartner, training_partner_id)
  end
end
