defmodule Seshon.Friendships.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  alias Seshon.Accounts.User

  schema "friendships" do
    belongs_to :user_one, User, foreign_key: :user_1
    belongs_to :user_two, User, foreign_key: :user_2
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
