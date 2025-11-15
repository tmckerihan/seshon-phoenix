defmodule SeshonWeb.EventsLive.Edit do
  use SeshonWeb, :live_view
  alias Seshon.Events
  alias SeshonWeb.EventFormComponent
  import Phoenix.Component

  @impl true
  def mount(params, _session, socket) do
    changeset =
      Events.change_event(
        Events.get_event!(socket.assigns.current_scope, params["id"]),
        %{},
        socket.assigns.current_scope
      )

    {:ok,
     assign(socket,
       event: Events.get_event!(socket.assigns.current_scope, params["id"]),
       form: to_form(changeset)
     )}
  end

  @impl true
  def handle_event("validate", %{"event" => params}, socket) do
    form =
      %Events.Event{}
      |> Events.change_event(params, socket.assigns.current_scope)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end
end
