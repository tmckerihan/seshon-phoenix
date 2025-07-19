defmodule Seshon.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:friendships) do
      add :user_1, references(:users, type: :id, on_delete: :delete_all)
      add :user_2, references(:users, type: :id, on_delete: :delete_all)
      add :accepted, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:friendships, [:user_2])
    create unique_index(:friendships, [:user_1])
  end
end
