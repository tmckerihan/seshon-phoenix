defmodule Seshon.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Seshon.Repo

  alias Seshon.Events.Event
  alias Seshon.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any event changes.

  The broadcasted messages match the pattern:

    * {:created, %Event{}}
    * {:updated, %Event{}}
    * {:deleted, %Event{}}

  """
  def subscribe_events(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Seshon.PubSub, "user:#{key}:events")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Seshon.PubSub, "user:#{key}:events", message)
  end

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events(scope)
      [%Event{}, ...]

  """
  def list_events(%Scope{} = scope) do
    from(e in Event,
      join: ue in "user_events",
      on: ue.event_id == e.id,
      where: ue.user_id == ^scope.user.id,
      select: e
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of events for the user and all their accepted friends.

  This function retrieves events that belong to:
  - The user themselves
  - All users who are friends with the user (accepted friendships only)

  ## Examples

      iex> list_associated_events(scope)
      [%Event{}, ...]

  """
  def list_associated_events(%Scope{} = scope, limit \\ 20, offset \\ 0) do
    # Get all friends of the user (both user_1 and user_2)
    friend_ids =
      from(fs in "friendships",
        where:
          fs.accepted == true and (fs.user_1 == ^scope.user.id or fs.user_2 == ^scope.user.id),
        select:
          fragment(
            "CASE WHEN ? = ? THEN ? ELSE ? END",
            fs.user_1,
            ^scope.user.id,
            fs.user_2,
            fs.user_1
          )
      )
      |> Repo.all()

    # Get events for the user and all their friends
    user_and_friend_ids = [scope.user.id | friend_ids]

    from(e in Event,
      join: ue in "user_events",
      on: ue.event_id == e.id,
      join: u in "users",
      on: u.id == ue.user_id,
      where: ue.user_id in ^user_and_friend_ids,
      select: %{
        event: e,
        is_owner: ue.is_owner,
        status: ue.status,
        owner_name:
          fragment(
            "CASE WHEN ? THEN ? || ' ' || ? ELSE (SELECT u2.first_name || ' ' || u2.last_name FROM user_events ue2 INNER JOIN users u2 ON u2.id = ue2.user_id WHERE ue2.event_id = ? AND ue2.is_owner = true) END",
            ue.is_owner,
            u.first_name,
            u.last_name,
            e.id
          )
      }
    )
    |> order_by([e, ue, u], desc: e.date)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(%Scope{} = scope, id) do
    Repo.get_by!(Event, id: id)
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(%Scope{} = scope, attrs) do
    Repo.transaction(fn ->
      with {:ok, event = %Event{}} <-
             %Event{}
             |> Event.changeset(attrs, scope)
             |> Repo.insert(),
           {:ok, _join} <-
             %Seshon.Events.UserEvent{}
             |> Seshon.Events.UserEvent.changeset(%{
               user_id: scope.user.id,
               event_id: event.id,
               is_owner: true,
               status: "GOING"
             })
             |> Repo.insert() do
        broadcast(scope, {:created, event})
        event
      else
        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
    |> case do
      {:ok, event} -> {:ok, event}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Scope{} = scope, %Event{} = event, attrs) do
    with {:ok, event = %Event{}} <-
           event
           |> Event.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, event})
      {:ok, event}
    end
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Scope{} = scope, %Event{} = event) do
    with {:ok, event = %Event{}} <-
           Repo.delete(event) do
      broadcast(scope, {:deleted, event})
      {:ok, event}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Scope{} = scope, %Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs, scope)
  end
end
