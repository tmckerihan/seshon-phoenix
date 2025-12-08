defmodule SeshonWeb.EventsLive.Show do
  use SeshonWeb, :live_view
  alias Seshon.Events
  alias Seshon.Accounts.User

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, assign_event_detail(socket, id)}
  end

  @impl true
  def handle_event("respond", %{"response" => response, "event-id" => event_id}, socket) do
    case Events.respond_to_event(event_id, %{"status" => response}, socket.assigns.current_scope) do
      {:ok, _user_event} ->
        {:noreply, assign_event_detail(socket, event_id)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to respond to event")
         |> assign_event_detail(event_id)}
    end
  end

  defp assign_event_detail(socket, event_id) do
    detail = Events.get_event_detail!(socket.assigns.current_scope, event_id)

    attendees_by_status =
      detail.responses
      |> Enum.group_by(& &1.status, & &1.user)
      |> normalize_attendees()

    current_user_status =
      detail.responses
      |> Enum.find_value("NOT_GOING", fn
        %{user: %User{id: user_id}, status: status} when user_id == socket.assigns.current_scope.user.id ->
          status

        _ ->
          nil
      end)

    socket
    |> assign(detail)
    |> assign(
      attendees_by_status: attendees_by_status,
      current_user_status: current_user_status,
      formatted_time: format_time(detail.event.date),
      page_title: detail.event.title
    )
  end

  defp normalize_attendees(attendees) do
    statuses = ["GOING", "MAYBE", "NOT_GOING"]

    Enum.into(statuses, %{}, fn status -> {status, Map.get(attendees, status, [])} end)
  end

  defp format_time(%DateTime{} = datetime) do
    %{
      weekday: Calendar.strftime(datetime, "%A"),
      date: Calendar.strftime(datetime, "%B %-d, %Y"),
      time: Calendar.strftime(datetime, "%-I:%M %p")
    }
  end

  defp format_time(_), do: %{weekday: "", date: "", time: ""}

  defp display_name(%User{} = user) do
    [user.first_name, user.last_name]
    |> Enum.reject(&is_nil_or_empty/1)
    |> case do
      [] -> user.email || "Guest"
      names -> Enum.join(names, " ")
    end
  end

  defp display_name(_), do: "Unknown guest"

  defp is_nil_or_empty(value), do: value in [nil, ""]
end
