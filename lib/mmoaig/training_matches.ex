defmodule Mmoaig.TrainingMatches do
  alias Mmoaig.TrainingMatches.TrainingMatch
  alias Mmoaig.TrainingPartners
  alias Mmoaig.Matches.Match
  alias Mmoaig.Matches.Participant
  alias Mmoaig.Matches.LogMessage
  alias Mmoaig.Matches.TrainingPartnerMatchParticipant
  alias Mmoaig.Repo
  alias Ecto.Multi

  def create_training_match(event_slug, training_match_params) do
    with {:ok, training_match} <- validate_training_match(training_match_params) do
      create_match(event_slug, training_match)
    else
      error -> error
    end
  end

  def change_training_match(%TrainingMatch{} = training_match, attrs \\ %{}) do
    TrainingMatch.changeset(training_match, attrs)
  end

  defp validate_training_match(training_match_params) do
    %TrainingMatch{}
    |> TrainingMatch.changeset(training_match_params)
    |> Ecto.Changeset.apply_action(:insert)
  end

  defp create_match(event_slug, training_match) do
    event = Mmoaig.Events.find_event_by_slug!(event_slug)

    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    training_partner_source_code =
      TrainingPartners.fetch_training_partner_source_code!(training_match.training_partner_id)

    {:ok, trainee_source_code} = File.read(training_match.trainee_file.path)

    match_params = %{
      event_id: event.id,
      status: "pending",
      runner_token: Ecto.UUID.generate(),
      rated: false
    }

    Multi.new()
    |> Multi.insert(:match, Mmoaig.Matches.change_match(%Match{}, match_params))
    |> Multi.insert(:round, fn %{match: match} ->
      Mmoaig.Matches.Round.changeset(%Mmoaig.Matches.Round{}, %{
        match_id: match.id,
        status: "pending"
      })
    end)
    |> Multi.insert(:match_created_message, fn %{match: match} ->
      LogMessage.changeset(%LogMessage{}, %{
        match_id: match.id,
        message: "Match created",
        level: "info"
      })
    end)
    |> Multi.insert_all(
      :participants,
      Participant,
      fn %{match: match} ->
        [
          %{
            match_id: match.id,
            source_code: training_partner_source_code,
            participant_number: 0,
            inserted_at: now,
            updated_at: now
          },
          %{
            match_id: match.id,
            source_code: trainee_source_code,
            participant_number: 1,
            inserted_at: now,
            updated_at: now
          }
        ]
      end,
      returning: true
    )
    |> Multi.insert(:training_partner_participant, fn %{
                                                        participants:
                                                          {2,
                                                           [
                                                             training_partner_participant,
                                                             _
                                                           ]}
                                                      } ->
      TrainingPartnerMatchParticipant.changeset(
        %TrainingPartnerMatchParticipant{},
        %{
          training_partner_id: training_match.training_partner_id,
          participant_id: training_partner_participant.id
        }
      )
    end)
    |> Repo.transaction()
  end
end
