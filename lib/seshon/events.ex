defmodule Seshon.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Seshon.Repo

  alias Seshon.Events.{Event, UserEvent}
  alias Seshon.Accounts.Scope
  alias Seshon.Friendships.Friendship

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
    friend_ids_subquery =
      from(f in Friendship,
        where: f.accepted == true,
        select:
          fragment(
            "CASE WHEN ? = ? THEN ? ELSE ? END",
            f.user_1,
            ^scope.user.id,
            f.user_2,
            f.user_1
          )
      )

    user_ids = [scope.user.id | Repo.all(friend_ids_subquery)]

    participant_events_subquery =
      from(ue in UserEvent,
        where: ue.user_id in ^user_ids,
        select: %{event_id: ue.event_id},
        distinct: true
      )

    from(e in Event,
      join: participant_event in subquery(participant_events_subquery),
      on: participant_event.event_id == e.id,
      left_join: current_user_ue in UserEvent,
      on: current_user_ue.event_id == e.id and current_user_ue.user_id == ^scope.user.id,
      select: %{
        event: e,
        is_owner: fragment("COALESCE(?, false)", current_user_ue.is_owner),
        status: fragment("COALESCE(?, ?)", current_user_ue.status, "NOT_GOING"),
        owner_name:
          fragment(
            """
            (SELECT u.first_name || ' ' || u.last_name
             FROM user_events ue
             INNER JOIN users u ON u.id = ue.user_id
             WHERE ue.event_id = ? AND ue.is_owner = true
             LIMIT 1)
            """,
            e.id
          )
      }
    )
    |> order_by([e, _participant_event, _current_user_ue], desc: e.date)
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
  def get_event!(%Scope{} = _scope, id) do
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
  def change_event(%Event{} = event, attrs \\ %{}, %Scope{} = scope) do
    Event.changeset(event, attrs, scope)
  end
end
