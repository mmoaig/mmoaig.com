defmodule MmoaigWeb.PageController do
  use MmoaigWeb, :controller

  alias Mmoaig.Events

  def home(conn, _params) do
    events = Events.list_events()
    render(conn, :home, events: events)
  end
end
