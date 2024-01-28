# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mmoaig.Repo.insert!(%Mmoaig.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Mmoaig.Repo
alias Mmoaig.Events.Event

events = [
  %Event{
    enabled: true,
    name: "Rock Paper Scissors",
    slug: "rock-paper-scissors"
  },
  %Event{
    enabled: false,
    name: "Tic Tac Toe",
    slug: "tic-tac-toe"
  },
  %Event{
    enabled: false,
    name: "Tanks",
    slug: "tanks"
  }
]

events
|> Enum.each(fn event ->
  event
  |> Mmoaig.Events.Event.changeset(%{})
  |> Repo.insert!(
    on_conflict: [set: [name: event.name, enabled: event.enabled]],
    conflict_target: :slug
  )
end)
