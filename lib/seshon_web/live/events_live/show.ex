defmodule SeshonWeb.EventsLive.Show do
  use SeshonWeb, :live_view
  alias Seshon.Events
  alias SeshonWeb.EventCardComponent

  @impl true
  def mount(params, _session, socket) do
    {:ok, assign(socket, event: Events.get_event!(socket.assigns.current_scope, params["id"]))}
  end
end
