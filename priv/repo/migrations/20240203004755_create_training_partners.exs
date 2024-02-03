defmodule Mmoaig.Repo.Migrations.CreateTrainingPartners do
  use Ecto.Migration

  def change do
    create table(:training_partners) do
      add :name, :string
      add :repository_url, :string
      add :event_id, references(:events, on_delete: :nothing)
      add :enabled, :boolean, default: false, null: false
      add :slug, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:training_partners, [:event_id])
    create unique_index(:training_partners, [:slug, :event_id])
  end
end
