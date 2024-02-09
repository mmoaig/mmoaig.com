defmodule MmoaigWeb.TrainingMatchController do
  use MmoaigWeb, :controller

  alias Mmoaig.TrainingMatches
  alias Mmoaig.TrainingMatches.TrainingMatch
  alias Mmoaig.TrainingPartners

  def new(conn, %{"event_slug" => event_slug}) do
    training_partners = TrainingPartners.list_training_partners_for_event(event_slug)
    changeset = TrainingMatches.change_training_match(%TrainingMatch{}, %{})
    render(conn, "new.html", training_partners: training_partners, changeset: changeset)
  end

  def create(conn, %{"event_slug" => event_slug, "training_match_params" => training_match_params}) do
    case TrainingMatches.create_training_match(event_slug, training_match_params) do
      {:ok, %{match: match}} ->
        redirect(conn, to: ~p"/training-matches/#{match.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        training_partners = TrainingPartners.list_training_partners_for_event(event_slug)
        render(conn, "new.html", training_partners: training_partners, changeset: changeset)
    end
  end
end
