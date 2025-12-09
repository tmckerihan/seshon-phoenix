defmodule SeshonWeb.EventCardComponent do
  use SeshonWeb, :html
  alias Seshon.Accounts.User

  def event_card(assigns) do
    ~H"""
    <!-- Plan Card Container -->
    <a href={~p"/events/#{@event.event.id}"} class="block h-full">
      <div class="relative h-full">
        <div class="absolute inset-x-6 bottom-0 h-3 bg-stone-200 rounded-b-xl opacity-50 translate-y-2 shadow-sm pointer-events-none"></div>

        <div class="relative bg-[#FDFBF7] rounded-xl shadow-[0_1px_3px_rgba(0,0,0,0.05),0_10px_25px_-5px_rgba(0,0,0,0.05)] border border-stone-200/70 overflow-hidden h-full">
          <div class="absolute -top-2 left-1/2 -translate-x-1/2 w-16 h-6 bg-yellow-100/80 rotate-1 backdrop-blur-sm z-10 border-l border-r border-white/40"></div>

          <!-- Header: Host -->
          <div class="px-5 pt-5 flex items-center gap-3">
            <.avatar user={@event.owner} size="md" class="shrink-0" />
            <div class="leading-tight">
              <div class="font-semibold text-stone-900">{owner_display_name(@event.owner)}</div>
              <div class="text-xs text-stone-500 font-medium">is hosting</div>
            </div>
          </div>

          <!-- Body -->
          <div class="p-5 flex gap-5 flex-col sm:flex-row">
            <!-- Polaroid icon -->
            <div class="shrink-0 pt-1 flex justify-center sm:block">
              <div class="bg-white p-2 pb-6 shadow-[0_2px_4px_rgba(0,0,0,0.1)] rotate-[-3deg] w-28 border border-stone-100">
                <div class="bg-blue-50 aspect-square w-full flex items-center justify-center border border-stone-100/60">
                  <span class="text-4xl leading-none">{@event.event.icon}</span>
                </div>
                <div
                  class="mt-2 text-center text-stone-500 font-semibold leading-none text-lg truncate"
                  style="font-family: 'Caveat', cursive;"
                >
                  {@event.event.location}
                </div>
              </div>
            </div>

            <!-- Details -->
            <div class="flex-1 min-w-0">
              <h3 class="font-serif text-3xl font-bold text-stone-900 leading-none mb-2">
                {@event.event.title}
              </h3>

              <div class="flex flex-col gap-1.5 mb-4">
                <div class="flex items-center gap-2 text-stone-600">
                  <svg class="w-4 h-4 text-orange-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span class="text-sm font-semibold">
                    {Calendar.strftime(@event.event.date, "%B %d, %Y at %I:%M %p")}
                  </span>
                </div>

                <div class="flex items-center gap-2 text-stone-600">
                  <svg class="w-4 h-4 text-stone-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657 13.414 20.9a1.998 1.998 0 0 1-2.827 0l-4.244-4.243a8 8 0 1 1 11.314 0Z" />
                  </svg>
                  <span class="text-sm border-b border-stone-300 border-dashed pb-0.5 hover:text-stone-900 hover:border-stone-900 transition-colors truncate">
                    {@event.event.location}
                  </span>
                </div>
              </div>

              <p class="text-stone-600 text-sm leading-relaxed line-clamp-4">
                {@event.event.description}
              </p>
            </div>
          </div>

          <!-- Footer -->
          <div class="bg-stone-50/70 px-5 py-4 border-t border-stone-100">
            <.event_response
              event={@event.event}
              is_owner={@event.is_owner}
              status={@event.status}
              joining_count={@event.joining_count || 0}
              going_attendees={Map.get(@event, :going_attendees, [])}
            />
          </div>
        </div>
      </div>
    </a>
    """
  end

  def event_response(assigns) do
    assigns =
      assigns
      |> assign_new(:response_options, &default_response_options/0)
      |> assign_new(:status, fn -> nil end)
      |> assign_new(:joining_count, fn -> 0 end)
      |> assign_new(:going_attendees, fn -> [] end)

    ~H"""
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between w-full gap-3">
      <!-- Attendees -->
      <% attendee_count = @joining_count || length(@going_attendees) %>
      <div class="flex items-center gap-3 min-w-0">
        <div class="flex -space-x-2 overflow-hidden">
          <.avatar
            :for={user <- Enum.take(@going_attendees, 4)}
            user={user}
            size="sm"
            class="ring-2 ring-white shadow-sm"
          />
          <div
            :if={attendee_count > length(@going_attendees)}
            class="inline-flex h-9 w-9 items-center justify-center rounded-full bg-white border border-stone-200 text-[11px] font-semibold text-stone-600 shadow-sm ring-2 ring-white"
          >
            +{attendee_count - length(@going_attendees)}
          </div>
          <div
            :if={@going_attendees == [] && attendee_count == 0}
            class="inline-flex h-9 w-9 items-center justify-center rounded-full bg-white border border-dashed border-stone-200 text-[11px] font-semibold text-stone-300 shadow-sm ring-2 ring-white"
          >
            ?
          </div>
        </div>
        <div class="text-xs text-stone-600 font-medium truncate">
          <span class="font-semibold text-stone-900">{attendee_count}</span> friend{if attendee_count != 1, do: "s"} in
        </div>
      </div>

      <!-- Response Buttons -->
      <%= if !@is_owner do %>
        <div class="flex flex-wrap gap-2 justify-end">
          <button
            :for={option <- @response_options}
            type="button"
            class={[
              "px-4 py-1.5 rounded-full text-xs font-semibold border transition-all duration-200",
              if @status == option.id do
                "bg-stone-900 text-white border-stone-900 shadow-md"
              else
                "bg-white text-stone-600 border-stone-200 hover:border-stone-400 hover:text-stone-900 shadow-sm"
              end
            ]}
            phx-click="respond"
            phx-value-response={option.id}
            phx-value-event-id={@event.id}
            onclick="event.preventDefault();"
          >
            {response_label(option.id)}
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp response_label("GOING"), do: "In"
  defp response_label("MAYBE"), do: "Maybe"
  defp response_label("NOT_GOING"), do: "Out"
  defp response_label(_), do: ""

  defp owner_display_name(%User{} = owner) do
    owner
    |> Map.take([:first_name, :last_name])
    |> Map.values()
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(" ")
    |> case do
      "" -> owner.email
      name -> name
    end
  end

  defp owner_display_name(_), do: "Unknown"

  defp default_response_options do
    [
      %{
        id: "GOING",
        label: "Going",
        description: "Count me in",
        icon: "hero-hand-thumb-up",
        class: "hover:border-primary hover:text-primary"
      },
      %{
        id: "MAYBE",
        label: "Maybe",
        description: "Depends how the day goes",
        icon: "hero-sparkles",
        class: "hover:border-secondary hover:text-secondary"
      },
      %{
        id: "NOT_GOING",
        label: "Not going",
        description: "Catch y'all next time",
        icon: "hero-hand-thumb-down",
        class: "hover:border-error hover:text-error"
      }
    ]
  end
end
