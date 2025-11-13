defmodule SeshonWeb.EventsLive.Edit do
  use SeshonWeb, :live_view
  alias Seshon.Events
  alias SeshonWeb.EventFormComponent
  import Phoenix.Component

  @impl true
  def mount(params, _session, socket) do
    changeset =
      Events.change_event(
        socket.assigns.current_scope,
        Events.get_event!(socket.assigns.current_scope, params["id"])
      )

    {:ok,
     assign(socket,
       event: Events.get_event!(socket.assigns.current_scope, params["id"]),
       form: to_form(changeset)
     )}
  end

  def handle_event("validate", %{"event" => params}, socket) do
    IO.inspect(params, label: "PARAMS")

    form =
      %Events.Event{}
      |> Events.change_event(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end
end
