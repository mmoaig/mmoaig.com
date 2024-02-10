defmodule MmoaigWeb.TrainingMatchLive.Show do
  use MmoaigWeb, :live_view

  alias Mmoaig.Matches

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    if connected?(socket), do: Matches.subscribe_to_match_updates(id)

    match = Matches.get_match!(id)
    log_messages = Matches.list_log_messages(match.id)

    {
      :noreply,
      socket
      |> assign(:match, match)
      |> assign(:log_messages, log_messages)
    }
  end

  def handle_info({:match_updated, match}, socket) do
    {:noreply, assign(socket, :match, match)}
  end
end
