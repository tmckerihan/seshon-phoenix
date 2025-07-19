defmodule Seshon.Events.UserEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "user_events" do
    field :is_owner, :boolean
    field :status, :string

    belongs_to :user, Seshon.Accounts.User, primary_key: true
    belongs_to :event, Seshon.Events.Event, primary_key: true
  end

  @doc false
  def changeset(user_event, attrs) do
    user_event
    |> cast(attrs, [:is_owner, :status, :user_id, :event_id])
    |> validate_required([:is_owner, :status, :user_id, :event_id])
  end
end
