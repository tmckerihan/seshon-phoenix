defmodule SeshonWeb.EventsLive.New do
  use SeshonWeb, :live_view
  alias Seshon.Events
  import Phoenix.Component

  @impl true
  def mount(_params, _session, socket) do
    changeset =
      Events.change_event(%Events.Event{}, %{}, socket.assigns.current_scope)

    {:ok, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"event" => params}, socket) do
    changeset =
      %Events.Event{}
      |> Events.change_event(params, socket.assigns.current_scope)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"event" => params}, socket) do
    case Events.create_event(socket.assigns.current_scope, params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully.")
         |> push_navigate(to: ~p"/events/#{event.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
