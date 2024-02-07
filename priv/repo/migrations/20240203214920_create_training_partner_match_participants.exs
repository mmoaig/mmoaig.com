defmodule Mmoaig.Repo.Migrations.CreateTrainingPartnerMatchParticipants do
  use Ecto.Migration

  def change do
    create table(:training_partner_match_participants) do
      add :training_partner_id, references(:training_partners, on_delete: :nothing), null: false
      add :participant_id, references(:match_participants, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:training_partner_match_participants, [:training_partner_id])
    create index(:training_partner_match_participants, [:participant_id])
  end
end
