defmodule MmoaigWeb.TrainingMatchLive.Show do
  alias Mmoaig.Matches.Runner
  use MmoaigWeb, :live_view

  alias Mmoaig.Matches
  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Gateway

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id} = params, _uri, socket) do
    match_runner_token = Map.get(params, "runner_token", nil)

    match =
      id
      |> Matches.get_match!()
      |> Match.load_participants()

    log_messages = Matches.list_log_messages(match.id)

    if connected?(socket) do
      Matches.subscribe_to_match_updates(id)

      if match.status == "pending" && match_runner_token == match.runner_token do
        Gateway.start_link(match.id, self())
        Matches.start_match_runner(match)
      end
    end

    {
      :noreply,
      socket
      |> assign(:match, match)
      |> assign(:log_messages, log_messages)
      |> assign(:participants, match.participants)
    }
  end

  def handle_info({:match_updated, match}, socket) do
    {:noreply, assign(socket, :match, match)}
  end

  def handle_info({:log_messages_updated, log_messages}, socket) do
    {:noreply, assign(socket, :log_messages, log_messages)}
  end

  def handle_cast({:request_turn, turn}, socket) do
    {:noreply, push_event(socket, "take_turn:#{turn.participant_id}", %{id: turn.id})}
  end

  def handle_event("take_turn", turn, socket) do
    Runner.record_turn(socket.assigns.match, turn)
    {:noreply, socket}
  end
end
