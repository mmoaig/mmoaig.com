defmodule MmoaigWeb.TrainingMatchLive.Show do
  use MmoaigWeb, :live_view

  alias Mmoaig.Matches
  alias Mmoaig.Matches.Match

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    if connected?(socket), do: Matches.subscribe_to_match_updates(id)

    match =
      id
      |> Matches.get_match!()
      |> Match.load_participants()

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

  def handle_info({:log_messages_updated, log_messages}, socket) do
    {:noreply, assign(socket, :log_messages, log_messages)}
  end
end
