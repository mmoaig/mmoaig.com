defmodule MmoaigWeb.TrainingMatchController do
  use MmoaigWeb, :controller

  alias Mmoaig.TrainingPartners
  alias Mmoaig.Matches
  alias Mmoaig.Events

  def new(conn, %{"event_slug" => event_slug}) do
    training_partners = TrainingPartners.list_training_partners_for_event(event_slug)
    changeset = Matches.change_match(%Matches.Match{}, %{})
    render(conn, "new.html", training_partners: training_partners, changeset: changeset)
  end

  def create(conn, %{"event_slug" => event_slug}) do
    event = Events.find_event_by_slug!(event_slug)

    match_params = %{
      event_id: event.id,
      status: "pending",
      runner_token: Ecto.UUID.generate(),
      rated: false
    }

    case Matches.create_match(match_params) do
      {:ok, match} ->
        Matches.start_runner(match)

        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: ~p"/training-matches/#{match.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        training_partners = TrainingPartners.list_training_partners_for_event(event_slug)
        render(conn, "new.html", training_partners: training_partners, changeset: changeset)
    end
  end
end
