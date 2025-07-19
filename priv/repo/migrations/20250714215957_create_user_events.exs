defmodule Seshon.Repo.Migrations.CreateUserEvents do
  use Ecto.Migration

  def change do
    create table(:user_events, primary_key: false) do
      add :is_owner, :boolean, null: false
      add :status, :string, null: false, default: "NOT_GOING"
      add :user_id, references(:users, on_delete: :delete_all)
      add :event_id, references(:events, on_delete: :delete_all)
    end

    create unique_index(:user_events, [:user_id, :event_id])
  end
end
