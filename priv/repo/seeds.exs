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
alias Mmoaig.Events
alias Mmoaig.TrainingPartners.TrainingPartner

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

training_partners = [
  %{
    event_slug: "rock-paper-scissors",
    name: "Rock Man",
    repository_url: "https://raw.githubusercontent.com/mmoaig/rock-man/main",
    slug: "rock-man",
    enabled: true
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

training_partners
|> Enum.each(fn training_partner ->
  event = Events.find_event_by_slug!(training_partner.event_slug)

  %TrainingPartner{
    name: training_partner.name,
    repository_url: training_partner.repository_url,
    event_id: event.id,
    slug: training_partner.slug,
    enabled: training_partner.enabled
  }
  |> Repo.insert!(
    on_conflict: [
      set: [
        name: training_partner.name,
        repository_url: training_partner.repository_url,
        enabled: training_partner.enabled
      ]
    ],
    conflict_target: [:slug, :event_id]
  )
end)
