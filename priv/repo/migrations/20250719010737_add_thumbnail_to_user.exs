defmodule Seshon.Repo.Migrations.AddThumbnailToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :thumbnail, :string, null: true
    end
  end
end
