defmodule Mmoaig.Repo.Migrations.CreateMatchGames do
  use Ecto.Migration

  def change do
    create table(:match_games) do
      add :status, :string, null: false
      add :round_id, references(:match_rounds, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:match_games, [:round_id])
  end
end
