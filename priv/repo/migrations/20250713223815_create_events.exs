defmodule Seshon.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string, null: false
      add :description, :string
      add :location, :string
      add :date, :utc_datetime, null: false
      add :icon, :string

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:user_id])
  end
end
