defmodule MmoaigWeb.TrainingMatchLive.Show do
  use MmoaigWeb, :live_view

  alias Mmoaig.Matches

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    match = Matches.get_match!(id)
    {:noreply, assign(socket, :match, match)}
  end
end
