defmodule Mmoaig.Repo.Migrations.CreateMatchLogMessages do
  use Ecto.Migration

  def change do
    create table(:match_log_messages) do
      add :level, :string
      add :message, :string
      add :match_id, references(:matches, on_delete: :nothing)
      add :participant_id, references(:match_participants, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:match_log_messages, [:match_id])
    create index(:match_log_messages, [:participant_id])
  end
end
