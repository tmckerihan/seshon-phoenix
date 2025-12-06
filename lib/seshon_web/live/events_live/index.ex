defmodule SeshonWeb.EventsLive.Index do
  use SeshonWeb, :live_view
  alias Seshon.Events
  alias Seshon.Friendships
  alias SeshonWeb.EventCardComponent

  @impl true
  def mount(_params, _session, socket) do
    events = Events.list_associated_events(socket.assigns.current_scope)
    friends = Friendships.list_friendships(socket.assigns.current_scope)
    {:ok, assign(socket, events: events, friends: friends)}
  end

  @impl true
  def handle_event("respond", %{"response" => response, "event-id" => event_id}, socket) do
    case Events.respond_to_event(event_id, %{"status" => response}, socket.assigns.current_scope) do
      {:ok, _user_event} ->
        {:noreply,
         socket
         |> assign(events: Events.list_associated_events(socket.assigns.current_scope))}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to respond to event")
         |> assign(events: Events.list_associated_events(socket.assigns.current_scope))}
    end
  end
end
