defmodule SeshonWeb.EventsLive.Index do
  use SeshonWeb, :live_view
  alias Seshon.Events
  alias SeshonWeb.EventCardComponent

  @impl true
  def mount(_params, _session, socket) do
    events = Events.list_associated_events(socket.assigns.current_scope)
    {:ok, assign(socket, events: events)}
  end
end
