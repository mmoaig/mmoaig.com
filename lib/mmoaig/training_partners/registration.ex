defmodule Mmoaig.TrainingPartners.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Mmoaig.TrainingPartners.TrainingPartner
  alias __MODULE__

  embedded_schema do
    field(:repository_url, :string)
    field(:entry_point, :string)
  end

  @finch Mmoaig.Finch
  @registration_location "registration.json"

  def fetch_registration_for_training_partner!(%TrainingPartner{repository_url: repository_url}) do
    :get
    |> Finch.build("#{repository_url}/#{@registration_location}")
    |> Finch.request!(@finch)
    |> ensure_successful_fetch()
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.put("repository_url", repository_url)
    |> build_registration!()
  end

  defp ensure_successful_fetch(response) do
    case response.status do
      200 ->
        response

      _ ->
        raise "Could not fetch registration for training partner. Got status #{response.status}"
    end
  end

  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:entry_point, :repository_url])
    |> validate_required([:entry_point, :repository_url])
  end

  defp build_registration!(attrs) do
    attrs = %{entry_point: attrs["entryPoint"], repository_url: attrs["repository_url"]}

    {:ok, registration} =
      %Registration{}
      |> changeset(attrs)
      |> apply_action(:create)

    registration
  end
end
