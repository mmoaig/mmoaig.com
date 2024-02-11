defmodule Mmoaig.Repo.Migrations.CreateMatchTurns do
  use Ecto.Migration

  def change do
    create table(:match_turns) do
      add :turn, :map
      add :status, :string, null: false
      add :game_id, references(:match_games, on_delete: :nothing), null: false
      add :participant_id, references(:match_participants, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:match_turns, [:game_id])
    create index(:match_turns, [:participant_id])
  end
end
