defmodule Seshon.Friendships.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friendships" do
    field :user_1, :id
    field :user_2, :id
    field :accepted, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:user_1, :user_2, :accepted])
    |> validate_required([:user_1, :user_2, :accepted])
    |> unique_constraint(:user_2)
    |> unique_constraint(:user_1)
  end
end
