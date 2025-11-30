defmodule SeshonWeb.EventCardComponent do
  use SeshonWeb, :html

  def event_card(assigns) do
    ~H"""
    <a href={~p"/events/#{@event.event}"} class="hover:bg-gray-100 flex-grow">
      <article
        class="bg-[#FFFFFF] rounded-[12px] mb-6 p-6 border border-[#E0DCD5] shadow-[0_4px_10px_rgba(0,0,0,0.06)] transition-transform transition-shadow duration-200 ease-in-out hover:shadow-[0_6px_15px_rgba(0,0,0,0.08)] hover:-translate-y-1"
        style="animation: fadeInSlideUp var(--animation-speed-fast) ease-out forwards; animation-delay: var(--animation-speed-stagger);"
      >
        <div class="flex items-center mb-2">
          <div class="avatar-2 w-[45px] h-[45px] rounded-full mr-4 flex items-center justify-center text-[#F8F6F2] font-bold text-[1.2rem] bg-cover bg-center border-2 border-[#FFFFFF] ring-1 ring-[#E0DCD5]">
          </div>
          <div>
            <div class="font-semibold text-[#333333]">{@event.owner_name}</div>
            <div class="text-[0.85rem] text-[#A0A0A0]">
              {Calendar.strftime(@event.event.date, "%B %d, %Y at %I:%M %p")}
            </div>
          </div>
        </div>
        <div>
          <div class="flex items-center mb-[0.7rem]">
            <div class="w-[45px] h-[45px] mr-3 flex items-center justify-center text-[1.8rem] shrink-0">
              {@event.event.icon}
            </div>
            <h3
              class="text-[1.3rem] font-bold text-[#2E4638]"
              style="font-family: var(--font-secondary);"
            >
              {@event.event.title}
            </h3>
          </div>
          <div class="text-[0.95rem] text-[#587464] mb-[1.2rem] flex flex-wrap gap-x-6 gap-y-[0.6rem] ml-3">
          </div>
          <p class="text-base text-[#333333] mb-6 leading-relaxed">
            {@event.event.description}
          </p>
        </div>
        <div class="flex justify-start items-center border-t border-[#E0DCD5] pt-[1.2rem]">
          <%= if !@event.is_owner do %>
            <.event_response
              event={@event.event}
              owner_name={@event.owner_name}
              status={@event.status}
            />
          <% end %>
        </div>
      </article>
    </a>
    """
  end

  def event_card_new(assigns) do
    ~H"""
    <!-- Plan Card Container -->
    <div class="bg-white rounded-[2rem] p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all duration-300 border border-stone-100 max-w-sm font-sans mx-auto">
      
    <!-- Header: User Info & Event Icon -->
      <div class="flex justify-between items-start mb-4">
        <div class="flex items-center gap-3">
          <!-- Avatar -->
          <div class="w-10 h-10 rounded-full bg-stone-100 overflow-hidden">
            <img
              src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop"
              alt="User"
              class="w-full h-full object-cover"
            />
          </div>
          <!-- User Name -->
          <div class="flex flex-col">
            <span class="text-sm font-semibold text-stone-900">Mike</span>
            <span class="text-xs text-stone-500">is planning...</span>
          </div>
        </div>
        
    <!-- Icon Circle (Amber Theme) -->
        <div class="w-12 h-12 rounded-full bg-amber-50 text-amber-700 flex items-center justify-center">
          <!-- Lucide Icon: Camera -->
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="22"
            height="22"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="opacity-80"
          >
            <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z" /><circle
              cx="12"
              cy="13"
              r="3"
            />
          </svg>
        </div>
      </div>
      
    <!-- Main Content -->
      <div class="mb-6">
        <!-- Title (Serif Font) -->
        <h3
          class="text-2xl font-serif text-stone-900 leading-tight mb-2"
          style="font-family: 'DM Serif Display', serif;"
        >
          {@event.event.title}
        </h3>
        <!-- Description -->
        <p class="text-stone-600 text-sm leading-relaxed font-light mb-4">
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
      <div class="flex items-center justify-between pt-4 border-t border-stone-100">
        <!-- Joining Count -->
        <div class="text-xs text-stone-400 font-medium">
          <span>
            <strong class="text-stone-800">2</strong> friends joining
          </span>
        </div>
        
    <!-- Response Buttons -->
        <div class="flex gap-2">
          <div class="flex bg-stone-50 p-1 rounded-full border border-stone-100">
            <!-- State: Selected (Going) -->
            <button class="px-4 py-1.5 rounded-full text-xs font-medium transition-all duration-300 bg-stone-800 text-white shadow-md">
              In
            </button>
            
    <!-- State: Default -->
            <button class="px-4 py-1.5 rounded-full text-xs font-medium transition-all duration-300 text-stone-500 hover:bg-stone-200">
              Maybe
            </button>
            
    <!-- State: Default -->
            <button class="px-4 py-1.5 rounded-full text-xs font-medium transition-all duration-300 text-stone-500 hover:bg-stone-200">
              Out
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def event_response(assigns) do
    assigns =
      assigns
      |> assign_new(:owner_name, fn -> nil end)
      |> assign_new(:response_options, &default_response_options/0)
      |> assign_new(:status, fn -> nil end)

    ~H"""
    <section class="w-full">
      <div class="w-full rounded-2xl border border-base-200 bg-base-100/80 p-4">
        <div class="flex flex-col gap-2 sm:flex-row sm:items-stretch">
          <button
            :for={option <- @response_options}
            type="button"
            class={[
              "btn btn-sm sm:btn-md btn-outline grow justify-start gap-3 rounded-2xl border-base-300 bg-base-100 text-left transition hover:border-base-content/40 hover:bg-base-200",
              option.class,
              case @status == option.id do
                true -> "border-primary text-primary"
                false -> "border-base-300 text-base-content/80"
              end
            ]}
            phx-click="respond"
            phx-value-response={option.id}
            phx-value-event-id={@event.id}
            onclick="event.preventDefault();"
          >
            <div class="flex h-9 w-9 items-center justify-center rounded-xl text-base-content/80">
              <.icon name={option.icon} class="h-5 w-5" />
            </div>
            <div class="flex flex-col leading-tight">
              <span class="text-sm font-semibold">{option.label}</span>
              <span :if={option.description} class="text-xs text-base-content/60">
                {option.description}
              </span>
            </div>
          </button>
        </div>
      </div>
    </section>
    """
  end

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
