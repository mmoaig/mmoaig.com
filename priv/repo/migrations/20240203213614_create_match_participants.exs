defmodule Mmoaig.Repo.Migrations.CreateMatchParticipants do
  use Ecto.Migration

  def change do
    create table(:match_participants) do
      add :source_code, :string, size: 2_097_152, null: false
      add :match_id, references(:matches, on_delete: :nothing), null: false
      add :participant_number, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:match_participants, [:match_id])
    create unique_index(:match_participants, [:match_id, :participant_number])
  end
end
