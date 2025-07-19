defmodule Seshon.FriendshipsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Seshon.Friendships` context.
  """

  @doc """
  Generate a unique friendship user_1.
  """
  def unique_friendship_user_1 do
    raise "implement the logic to generate a unique friendship user_1"
  end

  @doc """
  Generate a unique friendship user_2.
  """
  def unique_friendship_user_2 do
    raise "implement the logic to generate a unique friendship user_2"
  end

  @doc """
  Generate a friendship.
  """
  def friendship_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        accepted: true,
        user_1: unique_friendship_user_1(),
        user_2: unique_friendship_user_2()
      })

    {:ok, friendship} = Seshon.Friendships.create_friendship(scope, attrs)
    friendship
  end
end
