defmodule Mmoaig.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :status, :string, null: false
      add :rated, :boolean, default: false, null: false
      add :runner_token, :string, null: false
      add :event_id, references(:events, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:matches, [:event_id])
  end
end
