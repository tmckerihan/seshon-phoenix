defmodule SeshonWeb.EventsLive.Index do
  use SeshonWeb, :live_view
  alias Seshon.Events
  alias SeshonWeb.EventCardComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, events: Events.list_associated_events(socket.assigns.current_scope))}
  end
end
