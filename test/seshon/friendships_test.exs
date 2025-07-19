defmodule Seshon.FriendshipsTest do
  use Seshon.DataCase

  alias Seshon.Friendships

  describe "friendships" do
    alias Seshon.Friendships.Friendship

    import Seshon.AccountsFixtures, only: [user_scope_fixture: 0]
    import Seshon.FriendshipsFixtures

    @invalid_attrs %{user_1: nil, user_2: nil, accepted: nil}

    test "list_friendships/1 returns all scoped friendships" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      friendship = friendship_fixture(scope)
      other_friendship = friendship_fixture(other_scope)
      assert Friendships.list_friendships(scope) == [friendship]
      assert Friendships.list_friendships(other_scope) == [other_friendship]
    end

    test "get_friendship!/2 returns the friendship with given id" do
      scope = user_scope_fixture()
      friendship = friendship_fixture(scope)
      other_scope = user_scope_fixture()
      assert Friendships.get_friendship!(scope, friendship.id) == friendship
      assert_raise Ecto.NoResultsError, fn -> Friendships.get_friendship!(other_scope, friendship.id) end
    end

    test "create_friendship/2 with valid data creates a friendship" do
      valid_attrs = %{user_1: "7488a646-e31f-11e4-aace-600308960662", user_2: "7488a646-e31f-11e4-aace-600308960662", accepted: true}
      scope = user_scope_fixture()

      assert {:ok, %Friendship{} = friendship} = Friendships.create_friendship(scope, valid_attrs)
      assert friendship.user_1 == "7488a646-e31f-11e4-aace-600308960662"
      assert friendship.user_2 == "7488a646-e31f-11e4-aace-600308960662"
      assert friendship.accepted == true
      assert friendship.user_id == scope.user.id
    end

    test "create_friendship/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Friendships.create_friendship(scope, @invalid_attrs)
    end

    test "update_friendship/3 with valid data updates the friendship" do
      scope = user_scope_fixture()
      friendship = friendship_fixture(scope)
      update_attrs = %{user_1: "7488a646-e31f-11e4-aace-600308960668", user_2: "7488a646-e31f-11e4-aace-600308960668", accepted: false}

      assert {:ok, %Friendship{} = friendship} = Friendships.update_friendship(scope, friendship, update_attrs)
      assert friendship.user_1 == "7488a646-e31f-11e4-aace-600308960668"
      assert friendship.user_2 == "7488a646-e31f-11e4-aace-600308960668"
      assert friendship.accepted == false
    end

    test "update_friendship/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      friendship = friendship_fixture(scope)

      assert_raise MatchError, fn ->
        Friendships.update_friendship(other_scope, friendship, %{})
      end
    end

    test "update_friendship/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      friendship = friendship_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Friendships.update_friendship(scope, friendship, @invalid_attrs)
      assert friendship == Friendships.get_friendship!(scope, friendship.id)
    end

    test "delete_friendship/2 deletes the friendship" do
      scope = user_scope_fixture()
      friendship = friendship_fixture(scope)
      assert {:ok, %Friendship{}} = Friendships.delete_friendship(scope, friendship)
      assert_raise Ecto.NoResultsError, fn -> Friendships.get_friendship!(scope, friendship.id) end
    end

    test "delete_friendship/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      friendship = friendship_fixture(scope)
      assert_raise MatchError, fn -> Friendships.delete_friendship(other_scope, friendship) end
    end

    test "change_friendship/2 returns a friendship changeset" do
      scope = user_scope_fixture()
      friendship = friendship_fixture(scope)
      assert %Ecto.Changeset{} = Friendships.change_friendship(scope, friendship)
    end
  end
end
