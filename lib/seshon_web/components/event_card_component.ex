defmodule SeshonWeb.EventCardComponent do
  use SeshonWeb, :html
  alias Seshon.Accounts.User

  def event_card(assigns) do
    ~H"""
    <!-- Plan Card Container -->
    <a href={~p"/events/#{@event.event.id}"} class="block h-full">
    <div class="bg-white rounded-[2rem] p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all duration-300 border border-stone-100 w-full font-sans h-full min-h-[20rem] flex flex-col">

    <!-- Header: User Info & Event Icon -->
      <div class="flex justify-between items-start mb-4">
        <div class="flex items-center gap-3">
          <!-- Avatar -->
          <.avatar user={@event.owner} size="md" class="shrink-0" />
          <!-- User Name -->
          <div class="flex flex-col">
            <span class="text-sm font-semibold text-stone-900">
              {owner_display_name(@event.owner)}
            </span>
            <span class="text-xs text-stone-500">is planning...</span>
          </div>
        </div>

    <!-- Icon Circle (Amber Theme) -->
        <!-- outline icon -->
        <div class="w-12 h-12 rounded-full bg-amber-50 text-amber-700 flex items-center justify-center border border-amber-200 shadow-sm">
          {@event.event.icon}
        </div>
      </div>

    <!-- Main Content -->
      <div class="mb-6 flex-1">
        <!-- Title (Serif Font) -->
        <h3
          class="text-2xl font-serif text-stone-900 leading-tight mb-2"
          style="font-family: 'DM Serif Display', serif;"
        >
          {@event.event.title}
        </h3>
        <!-- Description -->
        <p class="text-stone-600 text-sm leading-relaxed font-light mb-4 line-clamp-3 overflow-hidden">
          {@event.event.description}
        </p>

    <!-- Details: Date & Location -->
        <div class="flex flex-col gap-2">
          <div class="flex items-center gap-2 text-stone-500 text-xs tracking-wide uppercase font-medium">
            <!-- Icon: Calendar -->
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              class="text-stone-400"
            >
              <rect width="18" height="18" x="3" y="4" rx="2" ry="2" /><line
                x1="16"
                x2="16"
                y1="2"
                y2="6"
              /><line x1="8" x2="8" y1="2" y2="6" /><line x1="3" x2="21" y1="10" y2="10" />
            </svg>
            <span>{Calendar.strftime(@event.event.date, "%B %d, %Y at %I:%M %p")}</span>
          </div>
          <div class="flex items-center gap-2 text-stone-500 text-xs tracking-wide uppercase font-medium">
            <!-- Icon: Map Pin -->
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              class="text-stone-400"
            >
              <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" /><circle
                cx="12"
                cy="10"
                r="3"
              />
            </svg>
            <span>{@event.event.location}</span>
          </div>
        </div>
      </div>

    <!-- Footer / Actions -->
      <div class="pt-4 border-t border-stone-100 mt-auto">
          <.event_response
            event={@event.event}
            is_owner={@event.is_owner}
            status={@event.status}
            joining_count={@event.joining_count || 0}
          />
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

    ~H"""
    <div class="flex items-center justify-between w-full">
      <!-- Joining Count -->
      <div class="text-xs text-stone-400 font-medium">
        <span>
          <strong class="text-stone-800">{@joining_count}</strong> friend{if @joining_count != 1, do: "s"} joining
        </span>
      </div>

    <!-- Response Buttons -->
      <%= if !@is_owner do %>
        <div class="flex gap-2">
          <div class="flex bg-stone-50 p-1 rounded-full border border-stone-100">
            <button
              :for={option <- @response_options}
              type="button"
              class={[
                "px-4 py-1.5 rounded-full text-xs font-medium transition-all duration-300",
                if @status == option.id do
                  "bg-stone-800 text-white shadow-md"
                else
                  "text-stone-500 hover:bg-stone-200"
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
