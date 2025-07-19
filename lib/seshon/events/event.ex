defmodule Seshon.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :date, :utc_datetime
    field :icon, :string

    many_to_many :users, Seshon.Accounts.User,
      join_through: Seshon.Events.UserEvent,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs, _scope) do
    event
    |> cast(attrs, [:title, :description, :location, :date, :icon])
    |> validate_required([:title, :description, :location, :date, :icon])
  end
end
