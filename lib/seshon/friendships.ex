defmodule Seshon.Friendships do
  @moduledoc """
  The Friendships context.
  """

  import Ecto.Query, warn: false
  alias Seshon.Repo

  alias Seshon.Friendships.Friendship
  alias Seshon.Accounts.Scope
  alias Seshon.Accounts.User

  @doc """
  Subscribes to scoped notifications about any friendship changes.

  The broadcasted messages match the pattern:

    * {:created, %Friendship{}}
    * {:updated, %Friendship{}}
    * {:deleted, %Friendship{}}

  """
  def subscribe_friendships(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Seshon.PubSub, "user:#{key}:friendships")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Seshon.PubSub, "user:#{key}:friendships", message)
  end

  @doc """
  Returns the list of friendships.

  ## Examples

      iex> list_friendships(scope)
      [%Friendship{}, ...]

  """
  def list_friendships(%Scope{} = scope) do
    Repo.all(
      from friendship in Friendship,
        where: friendship.user_1 == ^scope.user.id or friendship.user_2 == ^scope.user.id
    )
  end

  @doc """
  Gets a single friendship.

  Raises `Ecto.NoResultsError` if the Friendship does not exist.

  ## Examples

      iex> get_friendship!(123)
      %Friendship{}

      iex> get_friendship!(456)
      ** (Ecto.NoResultsError)

  """
  def get_friendship!(%Scope{} = scope, id) do
    friendship = Repo.get!(Friendship, id)

    if friendship.user_1 == scope.user.id or friendship.user_2 == scope.user.id do
      friendship
    else
      raise Ecto.NoResultsError, message: "Friendship not found"
    end
  end

  @doc """
  Creates a friendship.

  ## Examples

      iex> create_friendship(%{field: value})
      {:ok, %Friendship{}}

      iex> create_friendship(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_friendship(%Scope{} = scope, attrs) do
    with {:ok, friendship = %Friendship{}} <-
           %Friendship{}
           |> Friendship.changeset(attrs)
           |> Repo.insert() do
      broadcast(scope, {:created, friendship})
      {:ok, friendship}
    end
  end

  @doc """
  Updates a friendship.

  ## Examples

      iex> update_friendship(friendship, %{field: new_value})
      {:ok, %Friendship{}}

      iex> update_friendship(friendship, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_friendship(%Scope{} = scope, %Friendship{} = friendship, attrs) do
    if friendship.user_1 == scope.user.id or friendship.user_2 == scope.user.id do
      with {:ok, friendship = %Friendship{}} <-
             friendship
             |> Friendship.changeset(attrs)
             |> Repo.update() do
        broadcast(scope, {:updated, friendship})
        {:ok, friendship}
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a friendship.

  ## Examples

      iex> delete_friendship(friendship)
      {:ok, %Friendship{}}

      iex> delete_friendship(friendship)
      {:error, %Ecto.Changeset{}}

  """
  def delete_friendship(%Scope{} = scope, %Friendship{} = friendship) do
    if friendship.user_1 == scope.user.id or friendship.user_2 == scope.user.id do
      with {:ok, friendship = %Friendship{}} <-
             Repo.delete(friendship) do
        broadcast(scope, {:deleted, friendship})
        {:ok, friendship}
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking friendship changes.

  ## Examples

      iex> change_friendship(friendship)
      %Ecto.Changeset{data: %Friendship{}}

  """
  def change_friendship(%Scope{} = scope, %Friendship{} = friendship, attrs \\ %{}) do
    if friendship.user_1 == scope.user.id or friendship.user_2 == scope.user.id do
      Friendship.changeset(friendship, attrs)
    else
      raise Ecto.NoResultsError, message: "Friendship not found"
    end
  end

  def search_users_with_friendships_by_name(query, current_user_id, opts \\ [])
      when is_binary(query) and byte_size(query) > 0 do
    limit = Keyword.get(opts, :limit, 20)

    User
    |> where([u], ilike(u.first_name, ^"%#{query}%") or ilike(u.last_name, ^"%#{query}%"))
    |> where([u], u.id != ^current_user_id)
    |> join(:left, [u], f in Friendship, on: f.user_1 == u.id or f.user_2 == u.id)
    |> select([u, f], %{
      user: u,
      accepted: f.accepted,
      friendship_id: f.id,
      is_sender: f.user_1 == ^current_user_id,
      is_receiver: f.user_2 == ^current_user_id
    })
    |> limit(^limit)
    |> Repo.all()
  end

  def search_users_with_friendships_by_name(_, _, _), do: []

  @doc """
  Finds an existing friendship between two users.
  Returns nil if no friendship exists.
  """
  def find_friendship_between_users(user_1_id, user_2_id) do
    Repo.get_by(Friendship, user_1: user_1_id, user_2: user_2_id)
    |> case do
      nil -> Repo.get_by(Friendship, user_1: user_2_id, user_2: user_1_id)
      friendship -> friendship
    end
  end

  def request_friendship(%Scope{} = scope, user_id) do
    # Check if friendship already exists between these users
    existing_friendship = find_friendship_between_users(scope.user.id, user_id)

    cond do
      # If friendship exists and is not accepted, return positively without update
      existing_friendship && !existing_friendship.accepted ->
        {:ok, existing_friendship}

      # If friendship exists and is accepted, return error
      existing_friendship && existing_friendship.accepted ->
        {:error, :friendship_already_exists}

      # If no friendship exists, create new one
      true ->
        with {:ok, friendship = %Friendship{}} <-
               %Friendship{}
               |> Friendship.changeset(%{user_1: scope.user.id, user_2: user_id, accepted: false})
               |> Repo.insert() do
          broadcast(scope, {:created, friendship})
          {:ok, friendship}
        end
    end
  end
end
