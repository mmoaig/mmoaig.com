defmodule MmoaigWeb.TrainingMatchController do
  use MmoaigWeb, :controller

  alias Mmoaig.TrainingPartners

  def new(conn, %{"event_slug" => event_slug}) do
    training_partners = TrainingPartners.list_training_partners_for_event(event_slug)
    render(conn, "new.html", training_partners: training_partners)
  end

  def create(conn, _params) do
    redirect(conn, to: ~p"/training-matches/id")
  end
end
