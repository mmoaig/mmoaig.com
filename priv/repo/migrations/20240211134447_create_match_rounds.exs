defmodule Mmoaig.Repo.Migrations.CreateMatchRounds do
  use Ecto.Migration

  def change do
    create table(:match_rounds) do
      add :status, :string, null: false
      add :match_id, references(:matches, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:match_rounds, [:match_id])
  end
end
