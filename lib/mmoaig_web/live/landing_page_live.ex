defmodule MmoaigWeb.LandingPageLive do
  use MmoaigWeb, :live_view

  alias Mmoaig.Events

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:events, Events.list_events())}
  end
end
