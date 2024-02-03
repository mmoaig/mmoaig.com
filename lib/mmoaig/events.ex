defmodule Mmoaig.Events do
  import Ecto.Query, warn: false
  alias Mmoaig.Repo

  alias Mmoaig.Events.Event

  def list_events do
    Repo.all(Event)
  end

  def find_event_by_slug!(slug) do
    Repo.get_by!(Event, slug: slug)
  end
end
